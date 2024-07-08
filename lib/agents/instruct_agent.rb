require_relative 'ollama_agent'

module Agents
  class InstructAgent < OllamaAgent

    def generate(options = {}, stream)
      ->(messages) {
        model = 'internlm2'
        prompt = messages.first[:content]

        llm.generate(
          { model:, prompt:, **options },
          &stream
        )
      }
    end
  end
end
