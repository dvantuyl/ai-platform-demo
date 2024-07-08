require_relative 'ollama_agent'

module Agents
  class ChatAgent < OllamaAgent
    def generate(options = {}, stream)
      ->(messages) {
        llm.chat(
          { model: 'llama3:instruct',
            messages: messages.flatten,
            **options },
          &stream
        )
      }
    end

    def merge_content(response)
      response.each_with_object("") do |item, acc|
        acc + item["content"]
      end
    end
  end
end
