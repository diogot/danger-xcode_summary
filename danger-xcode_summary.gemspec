# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcode_summary/gem_version'

Gem::Specification.new do |spec|
  spec.name          = 'danger-xcode_summary'
  spec.version       = XcodeSummary::VERSION
  spec.authors       = ['Diogo Tridapalli', 'Marcelo Fabri']
  spec.email         = ['me@diogot.com', 'me@marcelofabri.com']
  spec.description   = 'Show formatted xcodebuild output in your PRs.'
  spec.summary       = 'A [Danger](http://danger.systems) plugin that shows all build errors, ' \
                       'warnings and unit tests results generated from `xcodebuild`.'
  spec.homepage      = 'https://github.com/diogot/danger-xcode_summary'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency 'danger-plugin-api', '~> 1.0'
  spec.add_dependency 'xcresult'

  # General ruby development
  spec.add_development_dependency 'bundler', '>= 2.2.10'
  spec.add_development_dependency 'rake'

  #  Testing support
  spec.add_development_dependency 'rspec'

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'

  # If you want to work on older builds of ruby
  spec.add_development_dependency 'listen'

  # This gives you the chance to run a REPL inside your test
  # via
  #    binding.pry
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency 'pry'
end
