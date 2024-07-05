# frozen_string_literal: true

require 'roda'
require 'ollama-ai'

class App < Roda

	plugin :websockets
	plugin :common_logger
  plugin :render

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
			view('ai-stream')
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
