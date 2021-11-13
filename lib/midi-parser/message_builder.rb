module MIDIParser
  class MessageBuilder
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

    attr_reader :num_nibbles, :name, :clazz

    def self.build_system_exclusive(*message_data)
      MIDIEvents::SystemExclusive.new(*message_data)
    end

    def self.for_system_message(status)
      type = SYSTEM_MESSAGE.find { |type| type[:status].cover?(status) }
      new(type[:nibbles], type[:class])
    end

    def self.for_channel_message(status)
      type = CHANNEL_MESSAGE.find { |type| type[:status] == status }
      new(type[:nibbles], type[:class])
    end

    def initialize(num_nibbles, clazz)
      @num_nibbles = num_nibbles
      @clazz = clazz
    end

    def build(*message_data)
      @clazz.new(*message_data)
    end
  end
end
