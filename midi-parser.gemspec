require_relative 'lib/midi-parser/version'

Gem::Specification.new do |s|
  s.name        = 'midi-parser'
  s.version     = MIDIParser::VERSION
  s.date        = '2025-08-23'
  s.summary     = 'A Ruby  library for parsing MIDI Event Messages'
  s.description = 'MIDI Parser is a library for parsing MIDI Event Messages received from any MIDI device through other libraries such as midi-communications or unimidi'
  s.authors     = ['Javier Sánchez Yeste']
  s.email       = 'javier.sy@gmail.com'
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|samples)/}) }
  s.homepage    = 'https://github.com/javier-sy/midi-parser'
  s.license     = 'LGPL-3.0-or-later'

  s.required_ruby_version = '>= 2.7'

  s.metadata = {
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage,
    'documentation_uri' => 'https://www.rubydoc.info/gems/midi-parser'
  }

  s.add_runtime_dependency 'midi-events', '~> 0.7'

  s.add_development_dependency 'minitest', '~>5', '>= 5.14.4'
  s.add_development_dependency 'rake', '~>13', '>= 13.0.6'
  s.add_development_dependency 'shoulda-context', '~>2', '>= 2.0.0'
  s.add_development_dependency 'yard', '~> 0.9'
  s.add_development_dependency 'redcarpet', '~> 3.6'
  s.add_development_dependency 'webrick', '~> 1.8'
end
