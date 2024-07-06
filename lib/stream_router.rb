require_relative 'agents/internlm2_basic_agent.rb'

class StreamRouter

  attr_reader :connection

  def initialize(connection)
    @connection = connection
  end

  def start
    messages_streamed_from(@connection)
      .each(
        &parse_input >>
        Agents::Internalm2BasicAgent.new(connection).run
      )
  end

  private

  def messages_streamed_from(connection)
    Enumerator.new do |yielder|
      loop do
        message = connection.read
        break unless message

        yielder << message
      rescue Protocol::WebSocket::ClosedError
        print "\n\nConnection Error: #{e}\n"
      end
    end
  end

  def parse_input
    ->(input) {
      json = JSON.parse(input.buffer)
      json['user-input']
    }
  end
end
