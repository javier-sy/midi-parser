#
# Parse MIDI Messages
# (c)2021 Javier Sánchez Yeste for the modifications, licensed under LGPL 3.0 License
# (c)2011-2015 Ari Russo for original Nibbler library, licensed under Apache 2.0 License
#

# libs
require 'midi-events'

# modules
require 'midi-parser/data_processor'
require 'midi-parser/type_conversion'

# classes
require 'midi-parser/message_builder'
require 'midi-parser/parser'
require 'midi-parser/session'

require_relative 'midi-parser/version'

# A Ruby parser for raw MIDI data that converts bytes, hex strings, and nibbles
# into MIDIEvents message objects.
#
# MIDIParser accepts various input formats and incrementally parses MIDI data,
# supporting running status and System Exclusive messages.
#
# This library is part of the MusaDSL MIDI suite:
# - {https://github.com/javier-sy/midi-events MIDI Events} - MIDI message representation
# - {https://github.com/javier-sy/midi-parser MIDI Parser} - MIDI data parsing (this library)
# - {https://github.com/javier-sy/midi-communications MIDI Communications} - MIDI I/O
#
# @example Basic usage - create a parser and parse a complete message
#   parser = MIDIParser.new
#   message = parser.parse(0x90, 0x40, 0x40)
#   # => #<MIDIEvents::NoteOn @channel=0, @note=64, @velocity=64>
#
# @example Parsing from hex string
#   parser = MIDIParser.new
#   message = parser.parse("904040")
#   # => #<MIDIEvents::NoteOn @channel=0, @note=64, @velocity=64>
#
# @example Incremental parsing (piece by piece)
#   parser = MIDIParser.new
#   parser.parse("90")  # => []
#   parser.parse("40")  # => []
#   parser.parse("40")  # => [#<MIDIEvents::NoteOn ...>]
#
# @example Using running status
#   parser = MIDIParser.new
#   parser.parse(0x90, 0x40, 0x40)  # First note
#   parser.parse(0x40, 0x50)        # Second note using running status
#
# @example Checking the buffer
#   parser = MIDIParser.new
#   parser.parse("90", "40")
#   parser.buffer    # => ["9", "0", "4", "0"]
#   parser.buffer_s  # => "9040"
#
# @see Session The main parsing session class
# @see https://github.com/javier-sy/midi-events MIDIEvents library
#
# @api public
module MIDIParser
  # Creates a new parser session.
  #
  # This is a convenience method that instantiates a new {Session} object.
  #
  # @return [Session] a new parser session
  #
  # @example
  #   parser = MIDIParser.new
  #   parser.parse(0x90, 0x40, 0x40)
  def self.new(...)
    Session.new(...)
  end
end
