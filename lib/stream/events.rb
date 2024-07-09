module Stream
  class Events
    class << self
      def from(connection)
        Enumerator.new do |yielder|
          loop do
            message = connection.read
            break unless message

            yielder << message
          rescue Protocol::WebSocket::Error => e
            App.logger.error "Connection closed: #{e.message}"
          end
        end
      end

      def parse_message
        ->(message) {
          JSON.parse(message.buffer).symbolize_keys_deep!
        }
      end
    end
  end
end
