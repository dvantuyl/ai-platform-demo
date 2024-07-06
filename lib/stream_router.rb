require_relative 'agents/prompt_agent.rb'

class StreamRouter
  Context = Data.define(:message, :user_input) do
    NONE = Data.define

    def initialize(message: NONE, user_input: NONE)
      super(message:, user_input:)
    end
  end

  def self.start(connection)
    self.new.start(connection)
  end

  def start(connection)
    messages_streamed_from(connection)
      .each(&
        with_ctx >>
        parse_message >>
        Agents::PromptAgent.generate(&
          format_response >>
          write_to(connection)
        )
      )
  end

  private

  def messages_streamed_from(connection)
    Enumerator.new do |yielder|
      loop do
        message = connection.read
        break unless message

        yielder << message
      rescue Protocol::WebSocket::ClosedError => e
        print "\n\nConnection Error: #{e}\n"
      end
    end
  end

  def with_ctx(ctx = {})
    ->(message) {
      Context.new(**ctx.merge(message:))
    }
  end


  def parse_message
    ->(ctx) {
      json = JSON.parse(ctx.message.buffer)
      ctx.with(user_input: json['user-input'])
    }
  end

  def format_response
    ->(event, raw) {
      <<~HTML
        <span hx-swap-oob="beforeend:#ai-response">#{event['response']}</span>
      HTML
    }
  end

  def write_to(connection)
    ->(response) {
      connection.write response
      connection.flush
    }
  end

end
