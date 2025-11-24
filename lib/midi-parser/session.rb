module MIDIParser
  # A parser session that maintains state between parse calls.
  #
  # Session is the main interface for parsing MIDI data. It wraps the {Parser}
  # and provides a convenient API for parsing various input formats and
  # accessing the internal buffer.
  #
  # The session maintains a buffer of unparsed nibbles between calls, allowing
  # for incremental parsing of MIDI data as it arrives.
  #
  # @example Basic parsing
  #   session = MIDIParser::Session.new
  #   messages = session.parse(0x90, 0x40, 0x40)
  #   # => [#<MIDIEvents::NoteOn ...>]
  #
  # @example Incremental parsing
  #   session = MIDIParser::Session.new
  #   session.parse("90")  # => []
  #   session.parse("40")  # => []
  #   session.buffer       # => ["9", "0", "4", "0"]
  #   session.parse("40")  # => [#<MIDIEvents::NoteOn ...>]
  #
  # @example Mixed input types
  #   session = MIDIParser::Session.new
  #   session.parse("9", "0", 0x40, 64)
  #   # => [#<MIDIEvents::NoteOn ...>]
  #
  # @see MIDIParser.new Convenience constructor
  # @see Parser The underlying parser
  #
  # @api public
  class Session
    # Creates a new parser session.
    #
    # @example
    #   session = MIDIParser::Session.new
    def initialize
      @parser = Parser.new
    end

    # Returns the current buffer contents as an array of hex nibble strings.
    #
    # The buffer contains unparsed MIDI data waiting for more bytes
    # to complete a message.
    #
    # @return [Array<String>] array of hex nibble strings (e.g., ["9", "0", "4", "0"])
    #
    # @example
    #   session = MIDIParser::Session.new
    #   session.parse("90", "40")
    #   session.buffer  # => ["9", "0", "4", "0"]
    def buffer
      @parser.buffer
    end

    # Returns the current buffer contents as a single hex string.
    #
    # @return [String] concatenated hex string of buffer contents
    #
    # @example
    #   session = MIDIParser::Session.new
    #   session.parse("90", "40")
    #   session.buffer_s  # => "9040"
    def buffer_s
      @parser.buffer.join
    end
    alias buffer_hex buffer_s

    # Clears the parser buffer, discarding any unparsed data.
    #
    # @return [Array] empty array
    #
    # @example
    #   session = MIDIParser::Session.new
    #   session.parse("90", "40")
    #   session.clear_buffer
    #   session.buffer  # => []
    def clear_buffer
      @parser.buffer.clear
    end

    # Parses MIDI data and returns any complete messages.
    #
    # Accepts various input formats: bytes (Integer), hex strings (String),
    # nibbles, or arrays. Input is accumulated in an internal buffer until
    # complete MIDI messages can be formed.
    #
    # @param args [Array<Integer, String>] MIDI data in various formats:
    #   - Bytes as integers (e.g., 0x90, 0x40, 0x40)
    #   - Hex strings (e.g., "904040" or "90", "40", "40")
    #   - Nibbles as strings (e.g., "9", "0", "4", "0")
    #   - Mixed formats
    #
    # @return [Array<MIDIEvents::ChannelMessage, MIDIEvents::SystemMessage>]
    #   array of parsed MIDI message objects (empty if no complete messages)
    #
    # @example Parse bytes
    #   session.parse(0x90, 0x40, 0x40)
    #   # => [#<MIDIEvents::NoteOn @channel=0, @note=64, @velocity=64>]
    #
    # @example Parse hex string
    #   session.parse("904040")
    #   # => [#<MIDIEvents::NoteOn ...>]
    #
    # @example Parse multiple messages
    #   session.parse("90404080404000")
    #   # => [#<MIDIEvents::NoteOn ...>, #<MIDIEvents::NoteOff ...>]
    def parse(*args)
      queue = DataProcessor.process(args)
      @parser.process(queue)
    end
  end
end
