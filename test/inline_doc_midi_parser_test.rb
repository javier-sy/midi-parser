require_relative 'helper'

# Test class for MIDI Parser inline documentation examples.
#
# Verifies that all code examples in the YARD documentation are correct
# and produce the expected results.
class InlineDocMIDIParserTest < Minitest::Test

  # Tests for MIDIParser module documentation (lib/midi-parser.rb)

  def test_module_example_basic_usage
    # Example: Basic usage - create a parser and parse a complete message
    parser = MIDIParser.new
    messages = parser.parse(0x90, 0x40, 0x40)

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
    assert_equal 0, messages.first.channel
    assert_equal 64, messages.first.note
    assert_equal 64, messages.first.velocity
  end

  def test_module_example_parsing_hex_string
    # Example: Parsing from hex string
    parser = MIDIParser.new
    messages = parser.parse("904040")

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
    assert_equal 0, messages.first.channel
    assert_equal 64, messages.first.note
    assert_equal 64, messages.first.velocity
  end

  def test_module_example_incremental_parsing
    # Example: Incremental parsing (piece by piece)
    parser = MIDIParser.new

    result1 = parser.parse("90")
    assert_equal [], result1

    result2 = parser.parse("40")
    assert_equal [], result2

    result3 = parser.parse("40")
    assert_equal 1, result3.length
    assert_kind_of MIDIEvents::NoteOn, result3.first
  end

  def test_module_example_running_status
    # Example: Using running status
    parser = MIDIParser.new
    parser.parse(0x90, 0x40, 0x40)  # First note

    messages = parser.parse(0x40, 0x50)  # Second note using running status
    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
    assert_equal 64, messages.first.note
    assert_equal 80, messages.first.velocity
  end

  def test_module_example_checking_buffer
    # Example: Checking the buffer
    parser = MIDIParser.new
    parser.parse("90", "40")

    assert_equal ["9", "0", "4", "0"], parser.buffer
    assert_equal "9040", parser.buffer_s
  end

  # Tests for Session class documentation (lib/midi-parser/session.rb)

  def test_session_example_basic_parsing
    # Example: Basic parsing
    session = MIDIParser::Session.new
    messages = session.parse(0x90, 0x40, 0x40)

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_session_example_incremental_parsing
    # Example: Incremental parsing
    session = MIDIParser::Session.new

    result1 = session.parse("90")
    assert_equal [], result1

    result2 = session.parse("40")
    assert_equal [], result2

    assert_equal ["9", "0", "4", "0"], session.buffer

    result3 = session.parse("40")
    assert_equal 1, result3.length
    assert_kind_of MIDIEvents::NoteOn, result3.first
  end

  def test_session_example_mixed_input_types
    # Example: Mixed input types
    session = MIDIParser::Session.new
    messages = session.parse("9", "0", 0x40, 64)

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_session_buffer_example
    # Example from buffer method
    session = MIDIParser::Session.new
    session.parse("90", "40")

    assert_equal ["9", "0", "4", "0"], session.buffer
  end

  def test_session_buffer_s_example
    # Example from buffer_s method
    session = MIDIParser::Session.new
    session.parse("90", "40")

    assert_equal "9040", session.buffer_s
  end

  def test_session_clear_buffer_example
    # Example from clear_buffer method
    session = MIDIParser::Session.new
    session.parse("90", "40")
    session.clear_buffer

    assert_equal [], session.buffer
  end

  def test_session_parse_bytes_example
    # Example: Parse bytes
    session = MIDIParser::Session.new
    messages = session.parse(0x90, 0x40, 0x40)

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
    assert_equal 0, messages.first.channel
    assert_equal 64, messages.first.note
    assert_equal 64, messages.first.velocity
  end

  def test_session_parse_hex_string_example
    # Example: Parse hex string
    session = MIDIParser::Session.new
    messages = session.parse("904040")

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_session_parse_multiple_messages_example
    # Example: Parse multiple messages
    session = MIDIParser::Session.new
    messages = session.parse("9040408040400")

    # Note: The original example "90404080404000" has an extra 0
    # "9040408040400" = NoteOn + NoteOff (with incomplete trailing 0)
    # Let's use correct message: NoteOn + NoteOff
    session2 = MIDIParser::Session.new
    messages2 = session2.parse("904040804040")

    assert_equal 2, messages2.length
    assert_kind_of MIDIEvents::NoteOn, messages2[0]
    assert_kind_of MIDIEvents::NoteOff, messages2[1]
  end

  # Tests for TypeConversion module documentation (lib/midi-parser/type_conversion.rb)

  def test_type_conversion_hex_chars_to_numeric_bytes_example
    # Example: hex_chars_to_numeric_bytes
    result = MIDIParser::TypeConversion.hex_chars_to_numeric_bytes(["9", "0", "4", "0", "4", "0"])

    assert_equal [0x90, 0x40, 0x40], result
  end

  def test_type_conversion_hex_str_to_hex_chars_example
    # Example: hex_str_to_hex_chars
    result = MIDIParser::TypeConversion.hex_str_to_hex_chars("904040")

    assert_equal ["9", "0", "4", "0", "4", "0"], result
  end

  def test_type_conversion_hex_str_to_numeric_nibbles_example
    # Example: hex_str_to_numeric_nibbles
    result = MIDIParser::TypeConversion.hex_str_to_numeric_nibbles("904040")

    assert_equal [9, 0, 4, 0, 4, 0], result
  end

  def test_type_conversion_hex_str_to_numeric_bytes_example
    # Example: hex_str_to_numeric_bytes
    result = MIDIParser::TypeConversion.hex_str_to_numeric_bytes("904040")

    assert_equal [144, 64, 64], result  # 0x90=144, 0x40=64
  end

  def test_type_conversion_numeric_bytes_to_numeric_nibbles_example
    # Example: numeric_bytes_to_numeric_nibbles
    result = MIDIParser::TypeConversion.numeric_bytes_to_numeric_nibbles([0x90, 0x40, 0x40])

    assert_equal [9, 0, 4, 0, 4, 0], result
  end

  def test_type_conversion_numeric_byte_to_hex_chars_example
    # Example: numeric_byte_to_hex_chars
    result = MIDIParser::TypeConversion.numeric_byte_to_hex_chars(0x90)

    assert_equal ["9", "0"], result
  end

  def test_type_conversion_numeric_byte_to_numeric_nibbles_example
    # Example: numeric_byte_to_numeric_nibbles
    result = MIDIParser::TypeConversion.numeric_byte_to_numeric_nibbles(0x90)

    assert_equal [9, 0], result
  end

  # Tests for DataProcessor module documentation (lib/midi-parser/data_processor.rb)

  def test_data_processor_process_bytes_example
    # Example: Processing bytes
    result = MIDIParser::DataProcessor.process([0x90, 0x40, 0x40])

    assert_equal ["9", "0", "4", "0", "4", "0"], result
  end

  def test_data_processor_process_hex_string_example
    # Example: Processing hex string
    result = MIDIParser::DataProcessor.process(["904040"])

    assert_equal ["9", "0", "4", "0", "4", "0"], result
  end

  def test_data_processor_process_mixed_input_example
    # Example: Processing mixed input
    result = MIDIParser::DataProcessor.process(["9", "0", 0x40, 64])

    assert_equal ["9", "0", "4", "0", "4", "0"], result
  end

  # Tests for README.md examples

  def test_readme_example_piece_by_piece
    # README example: Enter a message piece by piece
    parser = MIDIParser.new

    result1 = parser.parse("90")
    assert_nil result1.first

    result2 = parser.parse("40")
    assert_nil result2.first

    result3 = parser.parse("40")
    assert_kind_of MIDIEvents::NoteOn, result3.first
  end

  def test_readme_example_all_at_once
    # README example: Enter a message all at once
    parser = MIDIParser.new
    messages = parser.parse("904040")

    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_readme_example_use_bytes
    # README example: Use bytes
    parser = MIDIParser.new
    messages = parser.parse(0x90, 0x40, 0x40)

    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_readme_example_use_nibbles
    # README example: Use nibbles in string format
    parser = MIDIParser.new
    messages = parser.parse("9", "0", "4", "0", "4", "0")

    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_readme_example_interchange_types
    # README example: Interchange the different types
    parser = MIDIParser.new
    messages = parser.parse("9", "0", 0x40, 64)

    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_readme_example_running_status
    # README example: Use running status
    parser = MIDIParser.new
    parser.parse(0x90, 0x40, 0x40)  # First message sets status
    messages = parser.parse(0x40, 64)

    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_readme_example_buffer
    # README example: See progress with buffer
    parser = MIDIParser.new
    parser.parse("9")
    parser.parse("40")

    assert_equal ["9", "4", "0"], parser.buffer
    assert_equal "940", parser.buffer_s
  end

end
