module Agents
  class OllamaAgent

    def self.run
      self.new.run
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

    def write_to(output)
      -> (event, raw) {
        output.write ai_response(event['response'])
        output.flush
      }
    end

    def ai_response(value)
      <<~HTML
        <span hx-swap-oob="beforeend:#ai-response">#{value}</span>
      HTML
    end
  end
end
