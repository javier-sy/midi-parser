require 'helper'

class MIDIParser::FunctionalBufferTest < Minitest::Test
  context 'Parser::Buffer' do
    setup do
      @midi_parser = MIDIParser.new
    end

    should 'have processed string nibble' do
      @midi_parser.parse('9')
      assert_equal(['9'], @midi_parser.buffer)
    end

    should 'have processed numeric byte' do
      @midi_parser.parse(0x90)
      assert_equal(['9', '0'], @midi_parser.buffer)
    end

    should 'have processed string byte' do
      @midi_parser.parse('90')
      assert_equal(['9', '0'], @midi_parser.buffer)
    end

    should 'have processed array' do
      @midi_parser.parse([0x90])
      assert_equal(['9', '0'], @midi_parser.buffer)
    end

    should 'have processed numeric bytes' do
      @midi_parser.parse(0x90, 0x40)
      assert_equal(['9', '0', '4', '0'], @midi_parser.buffer)
    end

    should 'have processed string bytes' do
      @midi_parser.parse('90', '40')
      assert_equal(['9', '0', '4', '0'], @midi_parser.buffer)
    end

    should 'have processed two-byte string' do
      @midi_parser.parse('9040')
      assert_equal(['9', '0', '4', '0'], @midi_parser.buffer)
    end

    should 'have processed mixed bytes' do
      @midi_parser.parse('90', 0x40)
      assert_equal(['9', '0', '4', '0'], @midi_parser.buffer)
    end

    should 'have processed mixed nibble and byte' do
      @midi_parser.parse('9', 0x40)
      assert_equal(['9', '4', '0'], @midi_parser.buffer)
    end

    should 'have processed separate data' do
      @midi_parser.parse('9')
      @midi_parser.parse(0x40)
      assert_equal(['9', '4', '0'], @midi_parser.buffer)
    end
  end
end
