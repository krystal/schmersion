# frozen_string_literal: true

require_relative './lib/schmersion/schmersion_version'

Gem::Specification.new do |s|
  s.name          = 'schmersion'
  s.description   = 'A tool for generating CHANGELOGs and managing app versioning.'
  s.summary       = 'This is a tool for generating CHANGELOGs and managing app versioning.'
  s.homepage      = 'https://github.com/krystal/schmersion'
  s.version       = Schmersion::VERSION
  s.files         = Dir.glob('VERSION') + Dir.glob('{lib,cli,bin}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['adam@krystal.uk']
  s.required_ruby_version = '>= 2.6'
  s.bindir = 'bin'

  s.executables << 'schmersion'

  s.add_runtime_dependency 'colorize', '~> 0.8'
  s.add_runtime_dependency 'git', '>= 1.7.0', '< 2.0'
  s.add_runtime_dependency 'semantic', '~> 1.5'
  s.add_runtime_dependency 'swamp-cli', '~> 1.0'

  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'rubocop', '~> 0.85'
  s.add_development_dependency 'rubocop-performance', '~> 1.6'
  s.add_development_dependency 'rubocop-rspec', '~> 1.39'
end
