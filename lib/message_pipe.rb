class MessagePipe

  class Messages < Array
    def append(message)
      Messages.new([*self, message])
    end
  end

  def initialize(&block)
    block.call(Messages.new())
  end

  class << self
    def append(**message)
      ->(messages) {
        messages.append({**message})
      }
    end
  end
end
