module Components
  class AssistantOutput
    class << self

      def clear(connection)
        ->(*args) {
          connection.write <<~HTML
            <div id="assistant-output" hx-swap-oob="innerHTML:#assistant-output"></div>
          HTML
          connection.flush

          args
        }
      end

      def render_output_to(connection)
        ->(output) {
          connection.write <<~HTML
            <span hx-swap-oob="beforeend:#assistant-output">#{output}</span>
          HTML
          connection.flush

          output
        }
      end
    end
  end
end
