require_relative 'ollama_agent'

module Agents
  class PromptAgent < OllamaAgent

    def generate(options = {}, stream)
      ->(ctx) {
        llm.generate(
          { model: 'llama3:instruct', prompt: ctx.user_input, **options },
          &stream
        )
      }
    end
  end
end
