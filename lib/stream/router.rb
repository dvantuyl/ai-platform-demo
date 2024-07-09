module Stream
  class Router
    class << self

      def start(connection)
        # Stream messages from the user
        Events.from(connection)
          .each(&
            Events.parse_message >>
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
    end
  end
end
