module Agents
  class OllamaAgent

    def self.generate(&stream)
      self.new.generate(stream)
    end

    def self.parse_output
      ->(event, raw) {
        case symbolize_keys_deep!(event)
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

    def self.symbolize_keys_deep!(h)
      case h
      in Hash
        h.transform_keys!(&:to_sym).transform_values! { |v| symbolize_keys_deep!(v) }
      in Array
        h.map! { |v| symbolize_keys_deep!(v) }
      else
        h
      end
    end
  end
end
