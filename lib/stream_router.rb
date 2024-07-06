require_relative 'agents/internlm2_basic_agent.rb'

class StreamRouter

  attr_reader :connection, :llm

  def initialize(connection, llm)
    @connection = connection
    @llm = llm
  end

  def start
    messages_streamed_from(@connection)
      .each(
        &parse_input >>
        Agents::Internalm2BasicAgent.new(llm, connection).run
      )
  end

  private

  def messages_streamed_from(connection)
    Enumerator.new do |yielder|
      loop do
        message = connection.read
        break unless message

        yielder << message
      rescue Protocol::WebSocket::ClosedError => e
        print "Connection closed: #{e}"
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
