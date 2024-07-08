require_relative 'agents/chat_agent.rb'
require_relative 'agents/instruct_agent.rb'

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
    clear_assistant_output(connection).call

    # Initial message to start the conversation
    Agents::ChatAgent.generate(&
      parse_output >>
      format_message >>
      write_to(connection)
    )

    # Stream messages from the user
    messages_streamed_from(connection)
      .each(&
        with_ctx >>
        clear_assistant_output(connection) >>
        parse_user_input >>
        Agents::InstructAgent.generate(&
          parse_output >>
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
        App.logger.error "Connection closed: #{e.message}"
      end
    end
  end

  def clear_assistant_output(connection)
    ->(ctx = nil) {
      connection.write <<~HTML
        <div id="assistant-output" hx-swap-oob="innerHTML:#assistant-output"></div>
      HTML

      ctx
    }
  end

  def with_ctx(ctx = {})
    ->(message) {
      Context.new(**ctx.merge(message:))
    }
  end


  def parse_user_input
    ->(ctx) {
      json = JSON.parse(ctx.message.buffer)
      ctx.with(user_input: json['user-input'])
    }
  end

  def parse_output
    ->(event, raw) {
      App.logger.info "Event: #{event.inspect}"
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

  def format_message
    ->(output) {
      <<~HTML
        <span hx-swap-oob="beforeend:#assistant-output">#{output}</span>
      HTML
    }
  end

  def format_response
    ->(output) {
      <<~HTML
        <span hx-swap-oob="beforeend:#assistant-output">#{output}</span>
      HTML
    }
  end

  def write_to(connection)
    ->(response) {
      connection.write response
      connection.flush
    }
  end

  def symbolize_keys_deep!(h)
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
