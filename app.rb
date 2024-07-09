# frozen_string_literal: true

require 'roda'
require 'ollama-ai'
require_relative 'lib/hash.rb'
require_relative 'lib/message_pipe.rb'
require_relative 'lib/stream/router.rb'
require_relative 'lib/stream/events.rb'
require_relative 'lib/agents/chat_agent.rb'
require_relative 'lib/agents/instruct_agent.rb'
require_relative 'lib/messages/system.rb'
require_relative 'lib/messages/user_welcome.rb'
require_relative 'lib/components/assistant_output.rb'

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
        Stream::Router.start(connection)
			end
		end
	end
end
