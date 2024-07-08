module Messages
  class UserWelcome
    class << self

      def append
        ->(messages) {
          messages.append({ role:, content:})
        }
      end

      private

      def role
        'user'
      end

      def content
        <<~MESSAGE
        At the start of my day, I would like a helpful greeting based on the following guidelines:

        ### Current Date and Time
        Greet me based on the Context's Current Date and Time
        Examples:
        - "Good Morning."
        - "Good Afternoon."
        - "Good Evening."
        - "Let's continue where we left off."

        ### User Action History
        Anticipate my needs based on the Context's User Action History

        ### Be Brief and Direct
        Don't be too verbose. Keep it short and sweet.

        Start our day and greet me with a message that helps determine our next action to take.
        MESSAGE
      end
    end
  end
end
