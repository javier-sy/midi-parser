module Nibbler

  class Parser

    attr_reader :buffer

    # @param [Hash] options
    # @option options [Symbol] :message_lib The name of a message library module eg MIDIMessage or Midilib
    def initialize(options = {})
      @running_status = nil
      @buffer = []

      initialize_message_library(options[:message_lib])
    end

    # Process the given nibbles and add them to the buffer
    # @param [Array<String, Fixnum>] nibbles
    # @return [Hash]
    def process(nibbles)
      report = {
        :messages => [],
        :processed => [],
        :rejected => []
      }
      pointer = 0
      @buffer += nibbles
      # Iterate through nibbles in the buffer until a status message is found
      while pointer <= (@buffer.length - 1)
        # fragment is the piece of the buffer to look at
        fragment = get_fragment(pointer)
        # See if there really is a message there
        unless (processed = nibbles_to_message(fragment)).nil?
          # if fragment contains a real message, reject the nibbles that precede it
          report[:rejected] += @buffer.slice(0, pointer)
          # and record it
          @buffer = fragment.dup # fragment now has the remaining nibbles for next pass
          fragment = nil # Reset fragment
          pointer = 0 # Reset iterator
          report[:messages] << processed[:message]
          report[:processed] += processed[:processed]
        else
          @running_status = nil
          pointer += 1
        end
      end
      report
    end

    # @return [Hash, nil]
    def nibbles_to_message(fragment)
      if fragment.length >= 2
        slice = fragment.slice(0..1).map(&:hex)
        compute_message(slice, fragment)
      end
    end

    private

    # Attempt to convert the given nibbles into a MIDI message
    # @param [Array<Fixnum>] nibbles
    # @return [Hash, nil]
    def compute_message(nibbles, fragment)
      case nibbles[0]
      when 0x8 then lookahead(6, fragment) { |status_2, bytes| @message.note_off(status_2, bytes[1], bytes[2]) }
      when 0x9 then lookahead(6, fragment) { |status_2, bytes| @message.note_on(status_2, bytes[1], bytes[2]) }
      when 0xA then lookahead(6, fragment) { |status_2, bytes| @message.polyphonic_aftertouch(status_2, bytes[1], bytes[2]) }
      when 0xB then lookahead(6, fragment) { |status_2, bytes| @message.control_change(status_2, bytes[1], bytes[2]) }
      when 0xC then lookahead(4, fragment) { |status_2, bytes| @message.program_change(status_2, bytes[1]) }
      when 0xD then lookahead(4, fragment) { |status_2, bytes| @message.channel_aftertouch(status_2, bytes[1]) }
      when 0xE then lookahead(6, fragment) { |status_2, bytes| @message.pitch_bend(status_2, bytes[1], bytes[2]) }
      when 0xF then
        case nibbles[1]
        when 0x0 then lookahead_sysex(fragment) { |bytes| @message.system_exclusive(*bytes) }
        when 0x1..0x6 then lookahead(6, fragment, :recursive => true) { |status_2, bytes| @message.system_common(status_2, bytes[1], bytes[2]) }
        when 0x8..0xF then lookahead(2, fragment) { |status_2, bytes| @message.system_realtime(status_2) }
        end
      else
        use_running_status(fragment) if possible_running_status?
      end
    end

    # Choose a MIDI message object library
    # @param [Symbol] lib The MIDI message library module eg MIDIMessage or Midilib
    # @return [Module]
    def initialize_message_library(lib)
      @message = case lib
      when :midilib then
        require "nibbler/midilib"
        ::Nibbler::Midilib
      else
        require "nibbler/midi-message"
        ::Nibbler::MIDIMessage
      end
    end

    # Is running status active?
    # @return [Boolean]
    def possible_running_status?
      !@running_status.nil?
    end

    def use_running_status(fragment)
      lookahead(@running_status[:num], fragment, :status_nibble => @running_status[:status_nibble], &@running_status[:callback])
    end

    # Get the data in the buffer for the given pointer
    # @param [Fixnum] pointer
    # @return [Array<String>]
    def get_fragment(pointer)
      @buffer[pointer, (@buffer.length - pointer)]
    end

    def lookahead(num, fragment, options = {}, &callback)
      # do we have enough nibbles for num bytes?
      if fragment.size >= num
        # if so shift those nibbles off of the array and call block with them
        nibbles = fragment.slice!(0, num)
        status_nibble ||= options[:status_nibble] || nibbles[1]

        # send the nibbles to the block as bytes
        # return the evaluated block and the remaining nibbles
        bytes = TypeConversion.hex_chars_to_numeric_bytes(nibbles)

        # record the fragment situation in case running status comes up next round
        @running_status = {
          :callback => callback,
          :num => num - 2,
          :status_nibble => status_nibble
        }

        {
          :message => yield(status_nibble.hex, bytes),
          :processed => nibbles
        }
      elsif num > 0 && !!options[:recursive]
        lookahead(num - 2, fragment, options, &callback)
      end
    end

    def lookahead_sysex(fragment, &block)
      @running_status = nil

      bytes = TypeConversion.hex_chars_to_numeric_bytes(fragment)
      unless (index = bytes.index(0xF7)).nil?
        {
          :message => yield(bytes.slice!(0, index + 1)),
          :processed => fragment.slice!(0, (index + 1) * 2)
        }
      end
    end

  end

end
