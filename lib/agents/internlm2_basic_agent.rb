require_relative 'base_agent'

module Agents
  class Internalm2BasicAgent < OllamaAgent

    def run
      ->(ctx) {
        llm.generate(
          { model: 'internlm2', prompt: ctx.user_input },
          &write_to(ctx.connection)
        )
      }
    end
  end
end
