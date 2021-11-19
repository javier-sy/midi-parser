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

#
# Parse MIDI Messages
#
module MIDIParser
  VERSION = '0.3.1'.freeze

  # Shortcut to a new parser session
  def self.new(...)
    Session.new(...)
  end
end
