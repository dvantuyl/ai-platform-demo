module Messages
  class Streamed
    def self.from(connection)
      ->(messages) {
        connection.read.each do |message|
          messages.update({ role: 'user', content: message })
        end
      }
      # Enumerator.new do |yielder|
      #   loop do
      #     message = connection.read
      #     break unless message

      #     yielder << message
      #   rescue e
      #     App.logger.error "Connection closed: #{e.message}"
      #   end
      # end
    end
  end
end
