module Messages
  class Message
    class << self
      def append(**args)
        ->(messages) {
          messages.append({ role:, content:, **args})
        }
      end
    end
  end
end
