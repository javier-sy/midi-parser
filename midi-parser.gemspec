Gem::Specification.new do |s|
  s.name        = 'midi-parser'
  s.version     = '0.3.1'
  s.date        = '2021-11-19'
  s.summary     = 'A Ruby  library for parsing MIDI Event Messages'
  s.description = 'MIDI Parser is a library for parsing MIDI Event Messages received from any MIDI device through other libraries such as midi-communications or unimidi'
  s.authors     = ['Javier Sánchez Yeste']
  s.email       = 'javier.sy@gmail.com'
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|samples)/}) }
  s.homepage    = 'https://github.com/javier-sy/midi-parser'
  s.license     = 'LGPL-3.0'

  s.required_ruby_version = '~> 2.7'

  # TODO
  #s.metadata    = {
    # "source_code_uri" => "https://",
    # "homepage_uri" => "",
    # "documentation_uri" => "",
    # "changelog_uri" => ""
  #}

  s.add_runtime_dependency 'midi-events', '~> 0.5', '>= 0.5.0'

  s.add_development_dependency 'minitest', '~> 5.14', '>= 5.14.4'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  s.add_development_dependency 'shoulda-context', '~> 2.0', '>= 2.0.0'
end
