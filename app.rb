# frozen_string_literal: true

require 'roda'
require 'ollama-ai'

class App < Roda

	plugin :websockets
	plugin :common_logger
  plugin :render


	route do |r|
		r.root do
			view('home')
		end

		r.is 'ai-stream' do
			r.websocket do |connection|
        StreamRouter.new(connection).start
			end
		end
	end
end
