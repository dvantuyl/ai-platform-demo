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

  def parse_input
    ->(input) {
      json = JSON.parse(input.buffer)
      json['user-input']
    }
  end


  def write_llm_output_to(output)
    ->(input) {
      llm.generate({ model: 'internlm2', prompt: input }) do |event, raw|
        puts "Event: #{event.inspect}"
        output.write ai_response(event['response'])
        output.flush
      end
    }
  end

	def input_streamed_from(connection)
		Enumerator.new do |yielder|
			loop do
				message = connection.read
				break unless message

				yielder << message
      rescue Protocol::WebSocket::ClosedError => e
        print "Connection closed: #{e}"
			end
		end
	end



	route do |r|
		r.root do
			view('ai-stream')
		end

		r.is 'ai-stream' do
			r.websocket do |connection|
        input_streamed_from(connection)
          .each(&parse_input >> write_llm_output_to(connection))
      end
		end
	end
end
