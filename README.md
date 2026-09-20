# MIDI Parser

[![Ruby Version](https://img.shields.io/badge/ruby-2.7+-red.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)

**Ruby Parser for Raw MIDI Messages**

This library is part of a suite of Ruby libraries for MIDI:

| Function | Library |
| --- | --- |
| MIDI Events representation | [MIDI Events](https://github.com/javier-sy/midi-events) |
| MIDI Data parsing | [MIDI Parser](https://github.com/javier-sy/midi-parser) |
| MIDI communication with Instruments and Control Surfaces | [MIDI Communications](https://github.com/javier-sy/midi-communications) |
| Low level MIDI interface to MacOS | [MIDI Communications MacOS Layer](https://github.com/javier-sy/midi-communications-macos) |
| Low level MIDI interface to Windows | [MIDI Communications Windows Layer](https://github.com/javier-sy/midi-communications-windows) |
| Low level MIDI interface to Linux | **TO DO** | 
| Low level MIDI interface to JRuby | **TO DO** | 

This library is based on [Ari Russo's](http://github.com/arirusso) library [Nibbler](https://github.com/arirusso/nibbler).

## Install

`gem install midi-parser`

or using Bundler, add this to your Gemfile

`gem "midi-parser"`

## Usage

```ruby
require 'midi-parser'

midi_parser = MIDIParser.new
```

Enter a message piece by piece:

```ruby
midi_parser.parse("90")
  => nil

midi_parser.parse("40")
  => nil

midi_parser.parse("40")
  => #<MIDIEvents::NoteOn:0x98c9818
       @channel=0,
       @data=[64, 100],
       @name="C3",
       @note=64,
       @status=[9, 0],
       @velocity=100,
       @verbose_name="Note On: C3">
```

Enter a message all at once:

```ruby
midi_parser.parse("904040")

  => #<MIDIEvents::NoteOn:0x98c9818
        @channel=0,
        @data=[64, 100],
        @name="C3",
        @note=64,
        @status=[9, 0],
        @velocity=100,
        @verbose_name="Note On: C3">
```

Use bytes:

```ruby
midi_parser.parse(0x90, 0x40, 0x40)
  => #<MIDIEvents::NoteOn:0x98c9818 ...>
```

You can use nibbles in string format:

```ruby
midi_parser.parse("9", "0", "4", "0", "4", "0")
  => #<MIDIEvents::NoteOn:0x98c9818 ...>
```

Interchange the different types:

```ruby
midi_parser.parse("9", "0", 0x40, 64)
  => #<MIDIEvents::NoteOn:0x98c9818 ...>
```

Use running status:

```ruby
midi_parser.parse(0x40, 64)
  => #<MIDIEvents::NoteOn:0x98c9818 ...>
```

Add an incomplete message:

```ruby
midi_parser.parse("9")
midi_parser.parse("40")
```

See progress:

```ruby
midi_parser.buffer
  => ["9", "4", "0"]

midi_parser.buffer_s
  => "940"
```

MIDI Parser generates [midi-events](http://github.com/javier-sy/midi-events) objects.

## Documentation

* [rdoc](http://rubydoc.info/github/javier-sy/midi-parser) 

## Differences between [MIDI Parser](https://github.com/javier-sy/midi-parser) and [Nibbler](https://github.com/arirusso/nibbler)
[MIDI Parser](https://github.com/javier-sy/midi-parser) is mostly a clone of [Nibbler](https://github.com/arirusso/nibbler) with some modifications:

* Removed logging attributes (messages, rejected, processed) to reduce parsing overhead 
* Updated dependencies versions
* Source updated to Ruby 2.7 code conventions (method keyword parameters instead of options = {}, hash keys as 'key:' instead of ':key =>', etc.)
* Changed backend library midi-message to midi-events
* Removed backend library MIDIlib
* Renamed module to MIDIParser instead of Nibbler
* Renamed gem to midi-parser instead of nibbler
* Minor docs fixing 

## Then, why does exist this library if it is mostly a clone of another library?

The author has been developing since 2016 a Ruby project called
[Musa DSL](https://github.com/javier-sy/musa-dsl) that needs a way
of representing MIDI Events and a way of communicating with
MIDI Instruments and MIDI Control Surfaces.

[Ari Russo](https://github.com/arirusso) has done a great job creating
several interdependent Ruby libraries that allow
MIDI Events representation ([MIDI Message](https://github.com/arirusso/midi-message)
and [Nibbler](https://github.com/arirusso/nibbler))
and communication with MIDI Instruments and MIDI Control Surfaces
([unimidi](https://github.com/arirusso/unimidi),
[ffi-coremidi](https://github.com/arirusso/ffi-coremidi) and others)
that, **with some modifications**, I've been using in MusaDSL.

After thinking about the best approach to publish MusaDSL
I've decided to publish my own renamed version of the modified dependencies because:

* The original libraries have features
  (buffering, very detailed logging and processing history information, not locking behaviour when waiting input midi messages)
  that are not needed in MusaDSL and, in fact,
  can degrade the performance on some use cases in MusaDSL.
* The requirements for **Musa DSL** users probably will evolve in time, so it will be easier to maintain an independent source code base.
* Some differences on the approach of the modifications vs the original library doesn't allow to merge the modifications on the original libraries.
* Then the renaming of the libraries is needed to avoid confusing existent users of the original libraries.
* Due to some of the interdependencies of Ari Russo libraries,
  the modification and renaming on some of the low level libraries (ffi-coremidi, etc.)
  forces to modify and rename unimidi library.

All in all I have decided to publish a suite of libraries optimized for MusaDSL use case that also can be used by other people in their projects.

## Author

* [yeste.studio](https://yeste.studio)

## Acknowledgements

Thanks to [Ari Russo](http://github.com/arirusso) for his ruby library [Nibbler](https://github.com/arirusso/nibbler) licensed as Apache License 2.0.

## License

MIDI Parser is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See [LICENSE](LICENSE).

**What this means for you.** Composing, performing and publishing music made with MIDI Parser carries no obligation: the music is yours. The GPL applies to *software*: if you distribute a program that includes or is built on MIDI Parser, that program must be released under the GPL too, with its source.

**Commercial license.** If you need MIDI Parser under terms its license does not cover — for instance, inside a closed product — yeste.studio offers a commercial license. Write to javier@yeste.studio.

**Versions.** From 1.0.0, MIDI Parser follows [Semantic Versioning](https://semver.org): breaking changes only come with a new major version.

[MIDI Parser](https://github.com/javier-sy/midi-parser) Copyright (c) 2021-2026 [yeste.studio](https://yeste.studio)

This library is based on [Ari Russo](http://arirusso.com)'s [Nibbler](https://github.com/arirusso/nibbler), Copyright (c) 2011-2015 Ari Russo, distributed under the Apache License 2.0; see [LICENSE.nibbler](LICENSE.nibbler). Files modified by yeste.studio.
