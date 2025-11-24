module MIDIParser
  # Low-level MIDI message parser.
  #
  # Parser handles the actual parsing logic, converting hex nibbles into
  # MIDI message objects. It maintains an internal buffer and supports
  # MIDI running status.
  #
  # This class is typically not used directly. Use {Session} instead for
  # a higher-level interface.
  #
  # @api private
  class Parser
    # @return [Array<String>] the current buffer of hex nibble strings
    attr_reader :buffer

    # Creates a new parser with empty buffer and running status.
    def initialize
      @running_status = RunningStatus.new
      @buffer = []
    end

    # Processes hex nibbles and returns any complete MIDI messages.
    #
    # Nibbles are accumulated in the buffer. When enough data is present
    # to form a complete MIDI message, it is parsed and returned.
    #
    # @param nibbles [Array<String>] hex nibble strings (e.g., ["9", "0", "4", "0"])
    # @return [Array<MIDIEvents::ChannelMessage, MIDIEvents::SystemMessage>]
    #   array of parsed messages
    def process(nibbles)
      messages = []
      pointer = 0
      @buffer += nibbles
      # Iterate through nibbles in the buffer until a status message is found
      while pointer <= (@buffer.length - 1)
        # fragment is the piece of the buffer to look at
        fragment = get_fragment(pointer)
        # See if there really is a message there
        unless (processed = nibbles_to_message(fragment)).nil?
          # if fragment contains a real message, reject the nibbles that precede it
          @buffer = fragment.dup # fragment now has the remaining nibbles for next pass
          fragment = nil # Reset fragment
          pointer = 0 # Reset iterator
          messages << processed[:message]
        else
          @running_status.cancel
          pointer += 1
        end
      end
      messages
    end

    # Attempts to convert a fragment of nibbles to a MIDI message.
    #
    # @param fragment [Array<String>] hex nibble strings (e.g., ["9", "0", "4", "0"])
    # @return [Hash, nil] hash with :message and :processed keys, or nil if incomplete
    def nibbles_to_message(fragment)
      if fragment.length >= 2
        # convert the part of the fragment to start with to a numeric
        slice = fragment.slice(0..1).map(&:hex)
        compute_message(slice, fragment)
      end
    end

    private

    # Attempt to convert the given nibbles into a MIDI message
    # @param [Array<Integer>] nibbles
    # @return [Hash, nil]
    def compute_message(nibbles, fragment)
      case nibbles[0]
      when 0x8..0xE then lookahead(fragment, MessageBuilder.for_channel_message(nibbles[0]))
      when 0xF
        case nibbles[1]
        when 0x0 then lookahead_for_sysex(fragment)
        else lookahead(fragment, MessageBuilder.for_system_message(nibbles[1]), recursive: true)
        end
      else
        lookahead_using_running_status(fragment) if @running_status.possible?
      end
    end

    # Attempt to convert the fragment to a MIDI message using the given fragment and cached running status
    # @param [Array<String>] fragment A fragment of data eg ["4", "0", "5", "0"]
    # @return [Hash, nil]
    def lookahead_using_running_status(fragment)
      lookahead(fragment, @running_status[:message_builder], offset: @running_status[:offset], status_nibble_2: @running_status[:status_nibble_2])
    end

    # Get the data in the buffer for the given pointer
    # @param [Integer] pointer
    # @return [Array<String>]
    def get_fragment(pointer)
      @buffer[pointer, (@buffer.length - pointer)]
    end

    # Attempts to build a MIDI message from a fragment with enough nibbles.
    #
    # @param fragment [Array<String>] hex nibble strings
    # @param message_builder [MessageBuilder] builder for the message type
    # @param options [Hash] additional options
    # @option options [String] :status_nibble_2 cached status nibble for running status
    # @option options [Boolean] :recursive whether to try shorter lengths
    # @option options [Integer] :offset nibble offset adjustment
    # @return [Hash, nil] hash with :message and :processed keys, or nil
    def lookahead(fragment, message_builder, options = {})
      offset = options.fetch(:offset, 0)
      num_nibbles = message_builder.num_nibbles + offset
      if fragment.size >= num_nibbles
        # if so shift those nibbles off of the array and call block with them
        nibbles = fragment.slice!(0, num_nibbles)
        status_nibble_2 ||= options[:status_nibble_2] || nibbles[1]

        # send the nibbles to the block as bytes
        # return the evaluated block and the remaining nibbles
        bytes = TypeConversion.hex_chars_to_numeric_bytes(nibbles)
        bytes = bytes[1..-1] if options[:status_nibble_2].nil?

        # record the fragment situation in case running status comes up next round
        @running_status.set(offset - 2, message_builder, status_nibble_2)

        message_args = [status_nibble_2.hex]
        message_args += bytes if num_nibbles > 2

        message = message_builder.build(*message_args)
        {
          message: message,
          processed: nibbles
        }
      elsif num_nibbles > 0 && !!options[:recursive]
        lookahead(fragment, message_builder, options.merge({ offset: offset - 2 }))
      end
    end

    def lookahead_for_sysex(fragment)
      @running_status.cancel
      bytes = TypeConversion.hex_chars_to_numeric_bytes(fragment)
      unless (index = bytes.index(0xF7)).nil?
        message_data = bytes.slice!(0, index + 1)
        message = MessageBuilder.build_system_exclusive(*message_data)
        {
          message: message,
          processed: fragment.slice!(0, (index + 1) * 2)
        }
      end
    end

    # Manages MIDI running status state.
    #
    # Running status is a MIDI optimization where the status byte can be omitted
    # if it's the same as the previous message.
    #
    # @api private
    class RunningStatus
      extend Forwardable

      def initialize
        @state = nil
      end

      def_delegators :@state, :[]

      # Clears the running status state.
      # @return [nil]
      def cancel
        @state = nil
      end

      # Checks if running status is available.
      # @return [Boolean] true if a previous status is cached
      def possible?
        !@state.nil?
      end

      # Stores the running status state.
      #
      # @param offset [Integer] nibble offset for running status
      # @param message_builder [MessageBuilder] builder for message type
      # @param status_nibble_2 [String] second status nibble
      # @return [Hash] the stored state
      def set(offset, message_builder, status_nibble_2)
        @state = {
          message_builder: message_builder,
          offset: offset,
          status_nibble_2: status_nibble_2
        }
      end
    end
  end
end
