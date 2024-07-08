class MessagePipe

  class Messages < Array
    def update(message)
      Messages.new([*self, message])
    end
  end

  def initialize(&block)
    block.call(Messages.new())
  end

end
