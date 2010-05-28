# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{officer}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["David FRANCOIS"]
  s.date = %q{2010-05-28}
  s.description = %q{Ruby interface that talks to OpenOffice}
  s.email = %q{david.francois@webflows.fr}
  s.extra_rdoc_files = ["README.rdoc", "lib/officer.rb"]
  s.files = ["README.rdoc", "Rakefile", "lib/officer.rb", "Manifest", "officer.gemspec"]
  s.homepage = %q{http://github.com/davout/officer}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Officer", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{officer}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby interface that talks to OpenOffice}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
