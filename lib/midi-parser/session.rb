module MIDIParser
  # A parser session
  #
  # Holds on to data that is not relevant to the parser between calls. For instance,
  # past messages, rejected bytes
  #
  class Session
    def initialize
      @parser = Parser.new
    end

    # The buffer
    # @return [Array<Object>]
    def buffer
      @parser.buffer
    end

    # The buffer as a single hex string
    # @return [String]
    def buffer_s
      @parser.buffer.join
    end
    alias buffer_hex buffer_s

    # Clear the parser buffer
    def clear_buffer
      @parser.buffer.clear
    end

    # Parse some input
    # @param [*Object] args
    # @return [Array<MIDIEvent>]
    def parse(*args)
      queue = DataProcessor.process(args)
      @parser.process(queue)
    end
  end
end
