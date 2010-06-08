# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{documentalist}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["David FRANCOIS"]
  s.date = %q{2010-06-08}
  s.description = %q{Ruby interface that talks to OpenOffice}
  s.email = %q{david.francois@webflows.fr}
  s.extra_rdoc_files = ["README.rdoc", "lib/DocumentConverter.py", "lib/officer.rb", "lib/open_office/server.rb"]
  s.files = ["README.rdoc", "Rakefile", "init.rb", "lib/DocumentConverter.py", "lib/officer.rb", "lib/open_office/server.rb", "officer.gemspec", "rails/init.rb", "test/fixtures/fixture.odt", "test/officer_test.rb", "test/open_office_test.rb", "Manifest", "documentalist.gemspec"]
  s.homepage = %q{http://github.com/davout/documentalist}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Documentalist", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{documentalist}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby interface that talks to OpenOffice}
  s.test_files = ["test/officer_test.rb", "test/open_office_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<zip>, [">= 2.0.2"])
    else
      s.add_dependency(%q<zip>, [">= 2.0.2"])
    end
  else
    s.add_dependency(%q<zip>, [">= 2.0.2"])
  end
end
