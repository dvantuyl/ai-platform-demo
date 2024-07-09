module Messages
  class Streamed
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
          symbolize_keys_deep!(JSON.parse(message.buffer))
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
end
