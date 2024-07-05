# frozen_string_literal: true

require 'roda'
require 'ollama-ai'

class App < Roda
	# Roda usually extracts HTML to separate files, but we'll inline it here.
	BODY = <<~HTML
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta charset="UTF-8">
			<title>WebSockets Example</title>
			<link rel="stylesheet" href="https://early.webawesome.com/webawesome@3.0.0-alpha.2/dist/themes/default.css" />
			<script type="module" src="https://early.webawesome.com/webawesome@3.0.0-alpha.2/dist/webawesome.loader.js"></script>
		  <script src="https://unpkg.com/htmx.org@2.0.0"></script>
		  <script src="https://unpkg.com/htmx.org@1.9.12/dist/ext/ws.js"></script>
		</head>
		<body>

			<div hx-ext="ws" ws-connect="/ai-stream">
				<form id="form" ws-send>
						<wa-input id="user" name="user-input"></wa-input>
						<wa-button type="submit">Send</wa-button>
				</form>

				<div id="ai-response" style="margin-top: 1rem;">
				</div>
			</div>

			<style>
			 body {
				display: flex;
				flex-direction: column;
				align-items: center;
			 }

			 body > div {
			 	width: clamp(365px, 80%, 3000px);
				min-height: calc(80vh);
				padding: 2rem;
				background-color: #f9f9f9;
			 }

			 form {
				width: 100%;
				display: flex;
				gap: 2rem;
			 }

			 wa-input {
				flex: 1;
			 }

			 wa-button {
				flex: none;
			 }

			 #ai-response {
				width: 100%;
				font-size: 1.25rem;
				color: #333;
			 }
			</style>
		</body>
		</html>
	HTML

	plugin :websockets
	plugin :common_logger

	def client
		@client ||= Ollama.new(
			credentials: { address: 'http://localhost:11434' },
			options: {
				connection: { adapter: :net_http },
				server_sent_events: true
			}
		)
	end

  def message(value)
    <<~HTML
			<span hx-swap-oob="beforeend:#ai-response">#{value}</span>
		HTML
  end

	def on_message(connection, message)
	  json = JSON.parse(message.buffer)
		user_input = json['user-input']
		puts "User input: #{user_input}"

		Async do |task|
			client.generate({ model: 'phi3', prompt: user_input }) do |event, raw|
				puts "Event: #{event.inspect}"
				connection.write message(event['response'])
				connection.flush
			end
		end

	rescue e
		connection.write message("Error: #{e.message}")
		connection.flush
	end

	def messages(connection)
		Enumerator.new do |yielder|
			loop do
				message = connection.read
				break unless message

				yielder << message
			end
		end
	end

	route do |r|
		r.root do
			BODY
		end

		r.is 'ai-stream' do
			r.websocket do |connection|
				messages(connection).each do |message|
					on_message(connection, message)
				end
			end
		end
	end
end

run App.freeze.app
