require_relative 'base_agent'

module Agents
  class Internalm2BasicAgent < BaseAgent

    def run
      ->(input) {
        llm.generate({ model: 'internlm2', prompt: input }) do |event, raw|
          puts "Event: #{event.inspect}"
          output.write ai_response(event['response'])
          output.flush
        end
      }
    end

    def ai_response(value)
      <<~HTML
        <span hx-swap-oob="beforeend:#ai-response">#{value}</span>
      HTML
    end
  end
end
