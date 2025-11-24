require_relative 'helper'

# Test class for README.md documentation examples.
#
# Verifies that all code examples in the README are correct
# and produce the expected results.
class DocReadmeTest < Minitest::Test

  def test_readme_create_parser
    # README: require 'midi-parser' / midi_parser = MIDIParser.new
    midi_parser = MIDIParser.new

    assert_kind_of MIDIParser::Session, midi_parser
  end

  def test_readme_enter_message_piece_by_piece
    # README: Enter a message piece by piece
    midi_parser = MIDIParser.new

    result1 = midi_parser.parse("90")
    assert_equal [], result1

    result2 = midi_parser.parse("40")
    assert_equal [], result2

    result3 = midi_parser.parse("40")
    assert_equal 1, result3.length
    assert_kind_of MIDIEvents::NoteOn, result3.first
    assert_equal 0, result3.first.channel
    assert_equal 64, result3.first.note
    assert_equal 64, result3.first.velocity
  end

  def test_readme_enter_message_all_at_once
    # README: Enter a message all at once
    midi_parser = MIDIParser.new

    messages = midi_parser.parse("904040")

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
    assert_equal 0, messages.first.channel
    assert_equal 64, messages.first.note
    assert_equal 64, messages.first.velocity
  end

  def test_readme_use_bytes
    # README: Use bytes
    midi_parser = MIDIParser.new

    messages = midi_parser.parse(0x90, 0x40, 0x40)

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_readme_use_nibbles_in_string_format
    # README: You can use nibbles in string format
    midi_parser = MIDIParser.new

    messages = midi_parser.parse("9", "0", "4", "0", "4", "0")

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_readme_interchange_different_types
    # README: Interchange the different types
    midi_parser = MIDIParser.new
    # First establish a status byte
    midi_parser.parse(0x90, 0x40, 0x40)

    # Now mix types with running status
    messages = midi_parser.parse("9", "0", 0x40, 64)

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
  end

  def test_readme_use_running_status
    # README: Use running status
    midi_parser = MIDIParser.new

    # First send a complete message to establish running status
    midi_parser.parse(0x90, 0x40, 0x40)

    # Then use running status (omit status byte)
    messages = midi_parser.parse(0x40, 64)

    assert_equal 1, messages.length
    assert_kind_of MIDIEvents::NoteOn, messages.first
    assert_equal 64, messages.first.note
    assert_equal 64, messages.first.velocity
  end

  def test_readme_add_incomplete_message
    # README: Add an incomplete message
    midi_parser = MIDIParser.new

    midi_parser.parse("9")
    midi_parser.parse("40")

    # Buffer should contain the incomplete data
    refute_empty midi_parser.buffer
  end

  def test_readme_see_progress_buffer
    # README: See progress - buffer
    midi_parser = MIDIParser.new

    midi_parser.parse("9")
    midi_parser.parse("40")

    # README shows: => ["9", "4", "0"]
    assert_equal ["9", "4", "0"], midi_parser.buffer
  end

  def test_readme_see_progress_buffer_s
    # README: See progress - buffer_s
    midi_parser = MIDIParser.new

    midi_parser.parse("9")
    midi_parser.parse("40")

    # README shows: => "940"
    assert_equal "940", midi_parser.buffer_s
  end

end
