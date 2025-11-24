module MIDIParser
  # Normalizes various input formats into hex nibble strings for parsing.
  #
  # DataProcessor accepts bytes, hex strings, nibbles, and arrays, converting
  # them into a consistent format (uppercase hex character strings) that can
  # be processed by the {Parser}.
  #
  # This module handles the complexity of accepting multiple input formats,
  # allowing users to mix and match formats in a single parse call.
  #
  # @note This outputs String objects rather than Integers because Ruby's
  #   0x0 and 0x00 are the same Integer, which would make nibbles and bytes
  #   ambiguous.
  #
  # @example Processing bytes
  #   MIDIParser::DataProcessor.process([0x90, 0x40, 0x40])
  #   # => ["9", "0", "4", "0", "4", "0"]
  #
  # @example Processing hex string
  #   MIDIParser::DataProcessor.process(["904040"])
  #   # => ["9", "0", "4", "0", "4", "0"]
  #
  # @example Processing mixed input
  #   MIDIParser::DataProcessor.process(["9", "0", 0x40, 64])
  #   # => ["9", "0", "4", "0", "4", "0"]
  #
  # @api private
  module DataProcessor
    extend self

    # Converts various input formats to an array of hex nibble strings.
    #
    # Invalid input (non-hex characters, out-of-range bytes) is filtered out.
    #
    # @param args [Array<String, Integer, Array>] input data in various formats
    # @return [Array<String>] array of uppercase hex nibble strings (e.g., ["9", "0", "4", "0"])
    #
    # @example
    #   DataProcessor.process([0x90, "40", 0x40])
    #   # => ["9", "0", "4", "0", "4", "0"]
    def process(*args)
      args.map { |arg| convert(arg) }.flatten.compact.map(&:upcase)
    end

    private

    # Converts a single value to hex character strings.
    #
    # @param value [Array, String, Integer] value to convert
    # @return [Array<String>, nil] hex character strings, or nil if invalid
    def convert(value)
      case value
      when Array then value.map { |arr| process(*arr) }.reduce(:+)
      when String then TypeConversion.hex_str_to_hex_chars(filter_string(value))
      when Integer then TypeConversion.numeric_byte_to_hex_chars(filter_numeric(value))
      end
    end

    # Filters numeric values to valid MIDI byte range.
    #
    # @param num [Integer] byte value to filter
    # @return [Integer, nil] the value if valid (0x00-0xFF), nil otherwise
    def filter_numeric(num)
      num if (0x00..0xFF).include?(num)
    end

    # Filters a string to only valid hex characters.
    #
    # @param string [String] input string
    # @return [String] string with only hex characters (0-9, A-F)
    def filter_string(string)
      string.gsub(/[^0-9a-fA-F]/, '').upcase
    end
  end
end
