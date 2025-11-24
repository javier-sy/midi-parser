module MIDIParser
  # Factory for building MIDI message objects from parsed data.
  #
  # MessageBuilder maps MIDI status bytes to the appropriate MIDIEvents
  # message classes and handles the construction of message objects.
  #
  # @api private
  class MessageBuilder
    # Channel message type mappings.
    # Maps status nibble to message class and expected nibble count.
    CHANNEL_MESSAGE = [
      {
        status: 0x8,
        class: MIDIEvents::NoteOff,
        nibbles: 6
      },
      {
        status: 0x9,
        class: MIDIEvents::NoteOn,
        nibbles: 6
      },
      {
        status: 0xA,
        class: MIDIEvents::PolyphonicAftertouch,
        nibbles: 6
      },
      {
        status: 0xB,
        class: MIDIEvents::ControlChange,
        nibbles: 6
      },
      {
        status: 0xC,
        class: MIDIEvents::ProgramChange,
        nibbles: 4
      },
      {
        status: 0xD,
        class: MIDIEvents::ChannelAftertouch,
        nibbles: 4
      },
      {
        status: 0xE,
        class: MIDIEvents::PitchBend,
        nibbles: 6
      }
    ].freeze

    # System message type mappings.
    # Maps status nibble to message class and expected nibble count.
    SYSTEM_MESSAGE = [
      {
        status: 0x1..0x6,
        class: MIDIEvents::SystemCommon,
        nibbles: 6
      },
      {
        status: 0x8..0xF,
        class: MIDIEvents::SystemRealtime,
        nibbles: 2
      }
    ].freeze

    # @return [Integer] number of nibbles expected for this message type
    attr_reader :num_nibbles

    # @return [String, nil] optional name for the message type
    attr_reader :name

    # @return [Class] the MIDIEvents class to instantiate
    attr_reader :clazz

    # Builds a System Exclusive message from raw data.
    #
    # @param message_data [Array<Integer>] SysEx message bytes
    # @return [MIDIEvents::SystemExclusive] the constructed message
    def self.build_system_exclusive(*message_data)
      MIDIEvents::SystemExclusive.new(*message_data)
    end

    # Creates a MessageBuilder for a system message type.
    #
    # @param status [Integer] the second status nibble (0x1-0xF)
    # @return [MessageBuilder] configured builder for the message type
    def self.for_system_message(status)
      type = SYSTEM_MESSAGE.find { |type| type[:status].cover?(status) }
      new(type[:nibbles], type[:class])
    end

    # Creates a MessageBuilder for a channel message type.
    #
    # @param status [Integer] the first status nibble (0x8-0xE)
    # @return [MessageBuilder] configured builder for the message type
    def self.for_channel_message(status)
      type = CHANNEL_MESSAGE.find { |type| type[:status] == status }
      new(type[:nibbles], type[:class])
    end

    # @param num_nibbles [Integer] expected nibble count for this message type
    # @param clazz [Class] MIDIEvents class to instantiate
    def initialize(num_nibbles, clazz)
      @num_nibbles = num_nibbles
      @clazz = clazz
    end

    # Builds a MIDI message from the given data.
    #
    # @param message_data [Array<Integer>] message data bytes
    # @return [MIDIEvents::ChannelMessage, MIDIEvents::SystemMessage] the constructed message
    def build(*message_data)
      @clazz.new(*message_data)
    end
  end
end
