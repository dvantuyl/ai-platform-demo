# frozen_string_literal: true

require 'roda'
require 'ollama-ai'

class App < Roda

	plugin :websockets
	plugin :common_logger
  plugin :render

	def llm
		@llm ||= Ollama.new(
			credentials: { address: 'http://localhost:11434' },
			options: {
				connection: { adapter: :net_http },
				server_sent_events: true
			}
		)
	end

  def ai_response(value)
    <<~HTML
			<span hx-swap-oob="beforeend:#ai-response">#{value}</span>
		HTML
  end

	def route_message(output, input)
	  json = JSON.parse(input.buffer)
		user_input = json['user-input']
		puts "User input: #{user_input}"

    llm.generate({ model: 'internlm2', prompt: user_input }) do |event, raw|
      puts "Event: #{event.inspect}"
      output.write ai_response(event['response'])
      output.flush
    end

	rescue e
		output.write ai_response("Error: #{e.message}")
		output.flush
	end

	def messages_streamed_from(connection)
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
				messages_streamed_from(connection).each do |message|
					route_message(connection, message)
				end
			end
		end
	end
end
