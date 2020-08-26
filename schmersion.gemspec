# frozen_string_literal: true

require_relative './lib/schmersion/version'

Gem::Specification.new do |s|
  s.name          = 'schmersion'
  s.description   = 'A tool for generating CHANGELOGs and managing app versioning.'
  s.summary       = 'This is a tool for generating CHANGELOGs and managing app versioning.'
  s.homepage      = 'https://github.com/krystal/schmersion'
  s.version       = Schmersion::VERSION
  s.files         = Dir.glob('VERSION') + Dir.glob('{lib}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['adam@krystal.uk']
  s.add_runtime_dependency 'git', '>= 1.7.0', '< 2.0'
  s.add_runtime_dependency 'colorize', '~> 0.8'
  s.add_runtime_dependency 'semantic', '~> 1.5'
end
