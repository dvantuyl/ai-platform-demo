require_relative 'agents/chat_agent.rb'
require_relative 'agents/instruct_agent.rb'
require_relative 'message_pipe.rb'
require_relative 'messages/streamed.rb'
require_relative 'messages/system.rb'
require_relative 'messages/user_welcome.rb'

class StreamRouter
  class << self

    def start(connection)
      # Stream messages from the user
      Messages::Streamed.from(connection)
        .each(&
          parse_message >>
          route_message(
            onloaded(connection),
            onuserinput(connection)
          ))
    end

    private

    def parse_message
      ->(message) {
        symbolize_keys_deep!(JSON.parse(message.buffer))
      }
    end

    def route_message(handleloaded, handleuserinput)
      ->(message) {
        case message
        in { loaded: _, ** }
          handleloaded.call
        in { userinput:, ** }
          handleuserinput.call(userinput)
        else
          App.logger.error "StreamRouter#route_message -> Unable to route: #{message}"
        end
      }
    end

    def onloaded(connection)
      -> {

        MessagePipe.new(&
          Messages::System.append >>
          Messages::UserWelcome.append >>
          clear_assistant_output(connection) >>
          Agents::ChatAgent.generate(&
            parse_output >>
            format_message >>
            write_to(connection)
          )
        )
      }
    end

    def onuserinput(connection)
      ->(userinput) {
        MessagePipe.new(&
          append_userinput(userinput) >>
          clear_assistant_output(connection) >>
          Agents::ChatAgent.generate(&
            parse_output >>
            format_message >>
            write_to(connection)
          )
        )
      }
    end

    def clear_assistant_output(connection)
      ->(*args) {
        connection.write <<~HTML
          <div id="assistant-output" hx-swap-oob="innerHTML:#assistant-output"></div>
        HTML

        args
      }
    end

    def append_userinput(content)
      ->(messages) {
        messages.append({ role: 'user', content: })
      }
    end

    def parse_output
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
