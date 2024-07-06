module Agents
  class OllamaAgent

    attr_reader :output

    def initialize(output)
      @output = output
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

    def write_out
      -> (event, raw) {
        puts "Event: #{event.inspect}"
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
