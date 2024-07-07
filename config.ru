# frozen_string_literal: true

is_dev = !ENV['RACK_ENV'] || ENV['RACK_ENV']== 'development'
puts "Development mode: #{is_dev}"
require 'rack/unreloader'

Unreloader = Rack::Unreloader.new(subclasses: %w'Roda', reload: is_dev){App}
Unreloader.require './app.rb'
Unreloader.require './lib/stream_router.rb'
Unreloader.require './lib/agents/ollama_agent.rb'
Unreloader.require './lib/agents/chat_agent.rb'
Unreloader.require './lib/agents/instruct_agent.rb'

run Unreloader
