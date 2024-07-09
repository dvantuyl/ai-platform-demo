require_relative 'agents/chat_agent.rb'
require_relative 'agents/instruct_agent.rb'
require_relative 'message_pipe.rb'
require_relative 'messages/streamed.rb'
require_relative 'messages/system.rb'
require_relative 'messages/user_welcome.rb'
require_relative 'components/assistant_output.rb'

class StreamRouter
  class << self

    def start(connection)
      # Stream messages from the user
      Messages::Streamed.from(connection)
        .each(&
          Messages::Streamed.parse_message >>
          route_message(
            on_loaded(connection),
            on_userinput(connection)
          ))
    end

    private

    def route_message(handle_loaded, handle_userinput)
      ->(message) {
        case message
        in { loaded: _, ** }
          handle_loaded.call
        in { userinput:, ** }
          handle_userinput.call(userinput)
        else
          App.logger.error "StreamRouter#route_message -> Unable to route: #{message}"
        end
      }
    end

    def on_loaded(connection)
      -> {
        MessagePipe.new(&
          Messages::System.append >>
          Messages::UserWelcome.append >>
          Components::AssistantOutput.clear(connection) >>
          Agents::ChatAgent.generate(&
            Agents::ChatAgent.parse_output >>
            Components::AssistantOutput.render_output_to(connection)
          )
        )
      }
    end

    def on_userinput(connection)
      ->(userinput) {
        MessagePipe.new(&
          MessagePipe.append({ role: 'user', content: userinput}) >>
          Components::AssistantOutput.clear(connection) >>
          Agents::ChatAgent.generate(&
            Agents::ChatAgent.parse_output >>
            Components::AssistantOutput.render_output_to(connection)
          )
        )
      }
    end

    def inspect
      ->(*args) { App.logger.info "ARGS: #{args.inspect}"; args}
    end

  end
end
