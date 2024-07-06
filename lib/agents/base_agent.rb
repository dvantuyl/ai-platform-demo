module Agents
  class BaseAgent

    attr_reader :llm, :output

    def initialize(llm, output)
      @llm = llm
      @output = output
    end
  end
end
