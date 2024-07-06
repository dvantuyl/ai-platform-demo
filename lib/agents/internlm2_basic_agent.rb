require_relative 'base_agent'

module Agents
  class Internalm2BasicAgent < OllamaAgent

    def generate(stream)
      ->(ctx) {
        llm.generate(
          { model: 'internlm2', prompt: ctx.user_input },
          &stream
        )
      }
    end
  end
end
