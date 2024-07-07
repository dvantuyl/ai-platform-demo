# frozen_string_literal: true

require 'roda'
require 'ollama-ai'

class App < Roda
  LOG_FILE_PATH = "./logs/#{ENV['RACK_ENV'] || 'development'}.log"

  plugin :common_logger, Logger.new(LOG_FILE_PATH)
	plugin :websockets
  plugin :render

  def self.logger
    self.opts[:common_logger]
  end


	route do |r|
		r.root do
			view('home')
		end

		r.is 'ai-stream' do
			r.websocket do |connection|
        StreamRouter.start(connection)
			end
		end
	end
end
