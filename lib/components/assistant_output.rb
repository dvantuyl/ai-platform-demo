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

      def append_output
        ->(output) {
          <<~HTML
            <span hx-swap-oob="beforeend:#assistant-output">#{output}</span>
          HTML
        }
      end
    end
  end
end
