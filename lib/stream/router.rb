module Stream
  class Router
    class << self

      def start(connection)
        # Stream messages from the user
        Events.from(connection)
          .each(&Events.parse_message >>
            ->(message) {
              case message
              in { loaded: _, ** }
                welcome_user(connection)
              in { userinput:, ** }
                reply_to_user(connection, userinput)
              else
                App.logger.error "StreamRouter#route_message -> Unable to route: #{message}"
              end
            })
      end

      private

      def welcome_user(connection)
        MessagePipe.new(&
          Messages::System.append(role: 'system') >>
          Messages::UserWelcome.append(role: 'user') >>
          Components::AssistantOutput.clear(connection) >>
          Agents::ChatAgent.generate(&
            Agents::ChatAgent.parse_output >>
            Components::AssistantOutput.render_output_to(connection)
          )
        )
      end

      def reply_to_user(connection, userinput)
        MessagePipe.new(&
          Messages::Message.append(role: 'user', content: userinput) >>
          Components::AssistantOutput.clear(connection) >>
          Agents::ChatAgent.generate(&
            Agents::ChatAgent.parse_output >>
            Components::AssistantOutput.render_output_to(connection)
          )
        )
      end

      # def provide_actions(connection)
      #   MessagePipe.new(&
      #     Messages::ContextHistory.append(role: 'system') >>
      #     Messages::ContactTool.append(role: 'system') >>
      #     Messages::PresentationTool.append(role: 'system') >>
      #     Commponents::ActionMenu.clear(connection) >>
      #     Agents::InstructAgent.generate(&
      #       Agents::InstructAgent.parse_output >>
      #       Components::ActionMenu.render_output_to(connection)
      #     )
      #   )
      # end
    end
  end
end
