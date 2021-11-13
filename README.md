# Nibbler

![nibbler](http://i.imgur.com/4BFZPJY.png)

Parse MIDI Messages

## Install

`gem install midi-nibbler`

or using Bundler, add this to your Gemfile

`gem "midi-nibbler"`

## Usage

```ruby
require 'nibbler'

nibbler = MIDIParser.new
```

Enter a message piece by piece

```ruby
nibbler.parse("90")
  => nil

nibbler.parse("40")
  => nil

nibbler.parse("40")
  => #<MIDIMessage::NoteOn:0x98c9818
       @channel=0,
       @data=[64, 100],
       @name="C3",
       @note=64,
       @status=[9, 0],
       @velocity=100,
       @verbose_name="Note On: C3">
```

Enter a message all at once

```ruby
nibbler.parse("904040")

  => #<MIDIMessage::NoteOn:0x98c9818
        @channel=0,
        @data=[64, 100],
        @name="C3",
        @note=64,
        @status=[9, 0],
        @velocity=100,
        @verbose_name="Note On: C3">
```

Use bytes

```ruby
nibbler.parse(0x90, 0x40, 0x40)
  => #<MIDIMessage::NoteOn:0x98c9818 ...>
```

You can use nibbles in string format

```ruby
nibbler.parse("9", "0", "4", "0", "4", "0")
  => #<MIDIMessage::NoteOn:0x98c9818 ...>
```

Interchange the different types

```ruby
nibbler.parse("9", "0", 0x40, 64)
  => #<MIDIMessage::NoteOn:0x98c9818 ...>
```

Use running status

```ruby
nibbler.parse(0x40, 64)
  => #<MIDIMessage::NoteOn:0x98c9818 ...>
```

Look at the messages we've parsed

```ruby
nibbler.messages
  => [#<MIDIMessage::NoteOn:0x98c9804 ...>
      #<MIDIMessage::NoteOn:0x98c9811 ...>]
```

Add an incomplete message

```ruby
nibbler.parse("9")
nibbler.parse("40")
```

See progress

```ruby
nibbler.buffer
  => ["9", "4", "0"]

nibbler.buffer_s
  => "940"
```

Pass in a timestamp

```ruby
nibbler.parse("904040", :timestamp => Time.now.to_i)
  => { :messages=> #<MIDIMessage::NoteOn:0x92f4564 ..>, :timestamp=>1304488440 }
```

Nibbler defaults to generate [midi-message](http://github.com/arirusso/midi-message) objects, but it is also possible to use [midilib](https://github.com/jimm/midilib)

```ruby
MIDIParser.new(:message_lib => :midilib)

nibbler.parse("9", "0", 0x40, "40")
=> "0: ch 00 on 40 40"
```

## Also see

* [midi-eye](http://github.com/arirusso/midi-eye), a MIDI event listener based on nibbler

## Differences between [MIDI Parser](https://github.com/javier-sy/midi-parser) and [Nibbler](https://github.com/arirusso/nibbler)
[MIDI Parser](https://github.com/javier-sy/midi-parser) is mostly a clone of [Nibbler](https://github.com/arirusso/nibbler) with some modifications:
* Renamed gem to midi-parser instead of nibbler
* Renamed module to MIDIParser instead of Nibbler
* Changed backend library midi-message to midi-events
* Removed backend library MIDIlib
* Removed logging to reduce parsing overhead
* Updated dependencies versions
* Source updated to Ruby 2.7 code conventions (method keyword parameters instead of options = {}, hash keys as 'key:' instead of ':key =>', etc.)
* Minor docs fixing 
* TODO: update tests to use rspec instead of rake
* TODO: migrate to (or confirm it's working ok on) Ruby 3.0 or Ruby 3.1


## Author

* [Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>

## License

Apache 2.0, See the file LICENSE

Copyright (c) 2011-2015 Ari Russo
