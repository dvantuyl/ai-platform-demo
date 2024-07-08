module Messages
  class Streamed
    def self.from(connection)
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
  end
end
