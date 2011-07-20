# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name = "documentalist"
  s.version = Documentalist::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["David FRANCOIS", "Nicolas PAPON"]
  s.date = "2011-07-19"
  s.description = "The smooth document management experience, usable as a Rails gem plugin or standalone in any ruby application"
  s.email = "david.francois@webflows.fr"
  s.homepage = "http://github.com/davout/documentalist"
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Documentalist}, %q{--main}, %q{README.rdoc}]
  s.rubyforge_project = "documentalist"
  s.summary = "The smooth document management experience, usable as a Rails gem plugin or standalone in any ruby application"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  #s.require_paths = ["lib"]

  #s.add_dependency('active_support', '>= 1.0.5')
  s.add_dependency("zip", ">= 2.0.2")
  s.add_dependency("resque", ">= 1.15.0")
  s.add_dependency("resque-status", ">= 0.2.3")
  s.add_dependency("SystemTimer", ">= 1.2")
  s.add_development_dependency("sqlite3-ruby", ">= 0")
  s.add_development_dependency("flexmock", ">= 0.8.6")
end