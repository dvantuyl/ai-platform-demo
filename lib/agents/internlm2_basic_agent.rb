require_relative 'base_agent'

module Agents
  class Internalm2BasicAgent < OllamaAgent

    def run
      ->(input) {
        llm.generate({ model: 'internlm2', prompt: input }, &write_out)
      }
    end
  end
end
