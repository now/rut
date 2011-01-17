# -*- coding: utf-8 -*-

$:.unshift File.expand_path('../lib', __FILE__)

require 'rut/version'

Gem::Specification.new do |s|
  s.name = 'rut'
  s.version = Rut::Version

  s.author = 'Nikolai Weibull'
  s.email = 'now@bitwi.se'
  s.homepage = 'http://github.com/now/rut'

  s.description = IO.read(File.expand_path('../README', __FILE__))
  s.summary = s.description[/^[[:alpha:]]+.*?\./]

  s.files = Dir['{lib,test}/**/*.rb'] + %w[README Rakefile]

  s.add_development_dependency 'yard', '~> 0.6.0'
end
