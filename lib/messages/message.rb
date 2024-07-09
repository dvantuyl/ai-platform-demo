module Messages
  class Message
    class << self
      def append
        ->(messages) {
          messages.append({ role:, content:})
        }
      end
    end
  end
end
