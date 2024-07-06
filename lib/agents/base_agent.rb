module Agents
  class OllamaAgent

    def self.generate(&stream)
      self.new.generate(stream)
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
