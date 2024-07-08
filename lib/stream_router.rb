require_relative 'agents/chat_agent.rb'
require_relative 'agents/instruct_agent.rb'
require_relative 'message_pipe.rb'
require_relative 'messages/streamed.rb'
require_relative 'messages/system.rb'
require_relative 'messages/user_welcome.rb'

class StreamRouter
  class << self

    def start(connection)

      MessagePipe.new(&

        # Initial message to start the conversation
        Messages::System.append >>
        Messages::UserWelcome.append >>
        clear_assistant_output(connection) >>
        Agents::ChatAgent.generate(&
          parse_output >>
          format_message >>
          write_to(connection)
        )

        # # Stream messages from the user
        # Messages::Streamed.from(connection)
        #   .each(&
        #     append_user_input >>
        #     clear_assistant_output(connection) >>
        #     Agents::InstructAgent.generate(&
        #       parse_output >>
        #       format_response >>
        #       write_to(connection)
        #     )
        #   )
      )

      Enumerator.new do |yielder|
        loop do
          message = connection.read
          break unless message

          yielder << message
        rescue e
          App.logger.error "Connection closed: #{e.message}"
        end
      end

    end

    private

    def clear_assistant_output(connection)
      ->(*args) {
        connection.write <<~HTML
          <div id="assistant-output" hx-swap-oob="innerHTML:#assistant-output"></div>
        HTML

        args
      }
    end

    def append_user_input
      ->(message) {
        json = JSON.parse(message.buffer)
        messages.update({ role: 'user', content: json['user-input'] })
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
end
