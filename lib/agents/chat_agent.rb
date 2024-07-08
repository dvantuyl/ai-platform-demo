require_relative 'ollama_agent'

module Agents
  class ChatAgent < OllamaAgent
    def generate(options = {}, stream)
      ->(messages) {
        App.logger.info "ChatAgent messages: #{messages}"
        llm.chat(
          { model: 'llama3:instruct',
            messages: messages.flatten,
            **options },
          &stream
        )
        # App.logger.info "ChatAgent response: #{merge_content(response)}"
      }
    end

    def merge_content(response)
      response.each_with_object("") do |item, acc|
        acc + item["content"]
      end
    end
  end
end
