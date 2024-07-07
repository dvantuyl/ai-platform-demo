require_relative 'ollama_agent'

module Agents
  class InstructAgent < OllamaAgent

    def generate(options = {}, stream)
      ->(ctx) {
        llm.generate(
          { model: 'internlm2', prompt: ctx.user_input, **options },
          &stream
        )
      }
    end
  end
end
