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

	route do |r|
		r.root do
			view('home')
		end

		r.is 'ai-stream' do
			r.websocket do |connection|
        StreamRouter.new(connection, llm).start
			end
		end
	end
end
