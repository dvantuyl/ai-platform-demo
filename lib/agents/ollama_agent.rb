module Agents
  class OllamaAgent

    def self.generate(&stream)
      self.new.generate(stream)
    end

    def self.parse_output
      ->(event, raw) {
        case event.symbolize_keys_deep!
        in { message: { content:, **}, **}
          content
        in { response:, **}
          response
        else
          App.logger.error "Unknown event: #{event}"
        end
      }
    end

    protected

    def llm
      @llm ||= Ollama.new(
        credentials: { address: 'http://localhost:11434' },
        options: {
          connection: { adapter: :net_http },
          server_sent_events: true
        }
      )
    end
  end
end
