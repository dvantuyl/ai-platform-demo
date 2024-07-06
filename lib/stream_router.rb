require_relative 'agents/internlm2_basic_agent.rb'

class StreamRouter
  Context = Data.define(:connection, :message, :user_input) do
    NONE = Data.define

    def initialize(connection:, message: NONE, user_input: NONE)
      super(connection:, message:, user_input:)
    end
  end

  def self.start(connection)
    self.new(connection)
  end

  def initialize(connection)
    messages_streamed_from(connection)
      .each(
        &with_ctx({ connection: connection }) >>
        parse_input >>
        Agents::Internalm2BasicAgent.generate(
          to_stream(connection)
        )
      )
  end

  private

  def to_stream(connection)
    ->(event, raw) {
      connection.write ai_response(event['response'])
      connection.flush
    }
  end


  def ai_response(value)
    <<~HTML
      <span hx-swap-oob="beforeend:#ai-response">#{value}</span>
    HTML
  end

  def with_ctx(ctx)
    ->(message) {
      Context.new(**ctx.merge(message: message))
    }
  end

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

  def parse_input
    ->(ctx) {
      json = JSON.parse(ctx.message.buffer)
      ctx.with(user_input: json['user-input'])
    }
  end
end
