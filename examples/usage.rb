#!/usr/bin/env ruby
$:.unshift(File.join('..', 'lib'))

#
# Walk through different ways to use Nibbler
#

require 'midi-parser'

midi_parser = MIDIParser.new

pp 'Enter a message piece by piece'

pp midi_parser.parse('90')

pp midi_parser.parse('40')

pp midi_parser.parse('40')

pp 'Enter a message all at once'

pp midi_parser.parse('904040')

pp 'Use Bytes'

pp midi_parser.parse(0x90, 0x40, 0x40) # this should return a message

pp 'Use nibbles in string format'

pp midi_parser.parse('9', '0', 0x40, 0x40) # this should return a message

pp 'Interchange the different types'

pp midi_parser.parse('9', '0', 0x40, 64)

pp 'Use running status'

pp midi_parser.parse(0x40, 64)

pp 'Add an incomplete message'

pp midi_parser.parse('9')
pp midi_parser.parse('40')

pp 'See progress'

pp midi_parser.buffer # should give you an array of bits

pp midi_parser.buffer_s # should give you an array of bytestrs

pp 'Pass in a timestamp'

# note:
# once you pass in a timestamp for the first time, midi-parser.messages will then return
# an array of message/timestamp hashes
# if there was no timestamp for a particular message it will be nil
#

pp midi_parser.parse('904040', timestamp: Time.now.to_i)

pp 'Add callbacks'

# you can list any properties of the message to check against.
# if they are all true, the callback will fire
#
# if you wish to use "or" or any more advanced matching I would just process the message after it"s
# returned
#
midi_parser.when({ class: MIDIMessage::NoteOn }) { |msg| puts 'bark' }
pp midi_parser.parse('904040')
pp midi_parser.parse('804040')
