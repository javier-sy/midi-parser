module MIDIParser
  # Utility module for converting between hex strings, nibbles, and bytes.
  #
  # TypeConversion provides methods to transform MIDI data between different
  # representations: hex character strings, numeric nibbles, and numeric bytes.
  #
  # @example Converting hex string to bytes
  #   TypeConversion.hex_str_to_numeric_bytes("904040")
  #   # => [0x90, 0x40, 0x40]
  #
  # @example Converting bytes to nibbles
  #   TypeConversion.numeric_byte_to_numeric_nibbles(0x90)
  #   # => [0x9, 0x0]
  #
  # @api private
  module TypeConversion
    extend self

    # Converts hex nibble strings to numeric bytes.
    #
    # @param nibbles [Array<String>] hex character strings (e.g., ["9", "0", "4", "0"])
    # @return [Array<Integer>] numeric bytes (e.g., [0x90, 0x40])
    #
    # @example
    #   hex_chars_to_numeric_bytes(["9", "0", "4", "0", "4", "0"])
    #   # => [0x90, 0x40, 0x40]
    def hex_chars_to_numeric_bytes(nibbles)
      nibbles = nibbles.dup
      # get rid of last nibble if there's an odd number
      # it will be processed later anyway
      nibbles.slice!(nibbles.length - 2, 1) if nibbles.length.odd?
      bytes = []
      until (nibs = nibbles.slice!(0, 2)).empty?
        byte = (nibs[0].hex << 4) + nibs[1].hex
        bytes << byte
      end
      bytes
    end

    # Splits a hex string into individual character strings.
    #
    # @param string [String] hex digit string (e.g., "904040")
    # @return [Array<String>] individual hex characters (e.g., ["9", "0", "4", "0", "4", "0"])
    #
    # @example
    #   hex_str_to_hex_chars("904040")
    #   # => ["9", "0", "4", "0", "4", "0"]
    def hex_str_to_hex_chars(string)
      string.split(//)
    end

    # Converts a hex string to numeric nibbles.
    #
    # @param string [String] hex digit string (e.g., "904040")
    # @return [Array<Integer>] numeric nibbles (e.g., [0x9, 0x0, 0x4, 0x0, 0x4, 0x0])
    #
    # @example
    #   hex_str_to_numeric_nibbles("904040")
    #   # => [9, 0, 4, 0, 4, 0]
    def hex_str_to_numeric_nibbles(string)
      bytes = hex_str_to_numeric_bytes(string)
      numeric_bytes_to_numeric_nibbles(bytes)
    end

    # Converts a hex string to numeric bytes.
    #
    # @param string [String] hex digit string (e.g., "904040")
    # @return [Array<Integer>] numeric bytes (e.g., [0x90, 0x40, 0x40])
    #
    # @example
    #   hex_str_to_numeric_bytes("904040")
    #   # => [144, 64, 64]
    def hex_str_to_numeric_bytes(string)
      chars = hex_str_to_hex_chars(string)
      hex_chars_to_numeric_bytes(chars)
    end

    # Converts numeric bytes to numeric nibbles.
    #
    # @param bytes [Array<Integer>] byte values (e.g., [0x90, 0x40])
    # @return [Array<Integer>] nibble values (e.g., [0x9, 0x0, 0x4, 0x0])
    #
    # @example
    #   numeric_bytes_to_numeric_nibbles([0x90, 0x40, 0x40])
    #   # => [9, 0, 4, 0, 4, 0]
    def numeric_bytes_to_numeric_nibbles(bytes)
      bytes.map { |byte| numeric_byte_to_numeric_nibbles(byte) }.flatten
    end

    # Converts a numeric byte to hex character strings.
    #
    # @param num [Integer] byte value (e.g., 0x90)
    # @return [Array<String>] hex characters (e.g., ["9", "0"])
    #
    # @example
    #   numeric_byte_to_hex_chars(0x90)
    #   # => ["9", "0"]
    def numeric_byte_to_hex_chars(num)
      nibbles = numeric_byte_to_numeric_nibbles(num)
      nibbles.map { |n| n.to_s(16) }
    end

    # Converts a numeric byte to numeric nibbles.
    #
    # @param num [Integer] byte value (e.g., 0x90)
    # @return [Array<Integer>] nibble values (e.g., [0x9, 0x0])
    #
    # @example
    #   numeric_byte_to_numeric_nibbles(0x90)
    #   # => [9, 0]
    def numeric_byte_to_numeric_nibbles(num)
      [((num & 0xF0) >> 4), (num & 0x0F)]
    end
  end
end
