require 'helper'

class MIDIParser::SessionTest < Minitest::Test
  def test_varying_length_strings
    session = MIDIParser::Session.new
    message = session.parse('9', '04', '040').first

    refute_nil message
    assert_equal(MIDIEvents::NoteOn, message.class)
  end

  def test_note_off
    session = MIDIParser::Session.new
    message = session.parse(0x80, 0x40, 0x40).first

    refute_nil message
    assert_equal(MIDIEvents::NoteOff, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)
  end

  def test_note_on
    session = MIDIParser::Session.new
    message = session.parse(0x90, 0x40, 0x40).first

    refute_nil message
    assert_equal(MIDIEvents::NoteOn, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)
  end

  def test_polyphonic_aftertouch
    session = MIDIParser::Session.new
    message = session.parse(0xA1, 0x40, 0x40).first

    refute_nil message
    assert_equal(MIDIEvents::PolyphonicAftertouch, message.class)
    assert_equal(1, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.value)
  end

  def test_control_change
    session = MIDIParser::Session.new
    message = session.parse(0xB2, 0x20, 0x20).first

    refute_nil message
    assert_equal(MIDIEvents::ControlChange, message.class)
    assert_equal(message.channel, 2)
    assert_equal(0x20, message.index)
    assert_equal(0x20, message.value)
  end

  def test_program_change
    session = MIDIParser::Session.new
    message = session.parse(0xC3, 0x40).first

    refute_nil message
    assert_equal(MIDIEvents::ProgramChange, message.class)
    assert_equal(3, message.channel)
    assert_equal(0x40, message.program)
  end

  def test_channel_aftertouch
    session = MIDIParser::Session.new
    message = session.parse(0xD3, 0x50).first

    refute_nil message
    assert_equal(MIDIEvents::ChannelAftertouch, message.class)
    assert_equal(3, message.channel)
    assert_equal(0x50, message.value)
  end

  def test_pitch_bend
    session = MIDIParser::Session.new
    message = session.parse(0xE0, 0x20, 0x00).first # center

    refute_nil message
    assert_equal(MIDIEvents::PitchBend, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x20, message.low)
    assert_equal(0x00, message.high)
  end

  def test_system_common_generic_3_bytes
    session = MIDIParser::Session.new
    message = session.parse(0xF1, 0x50, 0xA0).first

    refute_nil message
    assert_equal(MIDIEvents::SystemCommon, message.class)
    assert_equal(1, message.status[1])
    assert_equal(0x50, message.data[0])
    assert_equal(0xA0, message.data[1])
  end

  def test_system_common_generic_2_bytes
    session = MIDIParser::Session.new
    message = session.parse(0xF1, 0x50).first
    assert_equal(MIDIEvents::SystemCommon, message.class)
    assert_equal(1, message.status[1])
    assert_equal(0x50, message.data[0])
  end

  def test_system_common_generic_1_byte
    session = MIDIParser::Session.new
    message = session.parse(0xF1).first
    assert_equal(MIDIEvents::SystemCommon, message.class)
    assert_equal(1, message.status[1])
  end

  def test_system_realtime
    session = MIDIParser::Session.new
    message = session.parse(0xF8).first
    assert_equal(MIDIEvents::SystemRealtime, message.class)
    assert_equal(8, message.id)
  end
end
