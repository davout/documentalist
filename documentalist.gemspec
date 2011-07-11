# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{documentalist}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{David FRANCOIS}]
  s.date = %q{2011-07-09}
  s.description = %q{The smooth document management experience, usable as a Rails gem plugin or standalone in any ruby application}
  s.email = %q{david.francois@webflows.fr}
  s.extra_rdoc_files = [%q{README.rdoc}, %q{lib/backends/net_pbm.rb}, %q{lib/backends/odf_merge.rb}, %q{lib/backends/open_office.rb}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/LICENSE.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/README.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/docs/third-party-licenses/license-commons-io.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/docs/third-party-licenses/license-openoffice.org.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/docs/third-party-licenses/license-slf4j.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/docs/third-party-licenses/license-xstream.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/document-formats.xml}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/DEPENDENCIES.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/commons-cli-1.2.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/commons-io-1.4.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/jodconverter-2.2.2.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/jodconverter-cli-2.2.2.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/juh-3.0.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/jurt-3.0.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/ridl-3.0.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/slf4j-api-1.5.6.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/slf4j-jdk14-1.5.6.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/unoil-3.0.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/xstream-1.3.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/src/jodconverter-2.2.2-sources.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/src/jodconverter-cli-2.2.2-sources.jar}, %q{lib/backends/open_office/bridges/pyodconverter.py}, %q{lib/backends/open_office/server.rb}, %q{lib/backends/pdf_tools.rb}, %q{lib/backends/wkhtmltopdf.rb}, %q{lib/dependencies.rb}, %q{lib/documentalist.rake}, %q{lib/generators/config/config_generator.rb}, %q{lib/generators/config/templates/documentalist.yml}, %q{lib/tasks/documentalist.rake}]
  s.files = [%q{README.rdoc}, %q{Rakefile}, %q{config/default.yml}, %q{documentalist.gemspec}, %q{init_back.rb}, %q{lib/backends/net_pbm.rb}, %q{lib/backends/odf_merge.rb}, %q{lib/backends/open_office.rb}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/LICENSE.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/README.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/docs/third-party-licenses/license-commons-io.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/docs/third-party-licenses/license-openoffice.org.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/docs/third-party-licenses/license-slf4j.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/docs/third-party-licenses/license-xstream.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/document-formats.xml}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/DEPENDENCIES.txt}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/commons-cli-1.2.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/commons-io-1.4.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/jodconverter-2.2.2.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/jodconverter-cli-2.2.2.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/juh-3.0.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/jurt-3.0.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/ridl-3.0.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/slf4j-api-1.5.6.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/slf4j-jdk14-1.5.6.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/unoil-3.0.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/lib/xstream-1.3.1.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/src/jodconverter-2.2.2-sources.jar}, %q{lib/backends/open_office/bridges/jodconverter-2.2.2/src/jodconverter-cli-2.2.2-sources.jar}, %q{lib/backends/open_office/bridges/pyodconverter.py}, %q{lib/backends/open_office/server.rb}, %q{lib/backends/pdf_tools.rb}, %q{lib/backends/wkhtmltopdf.rb}, %q{lib/dependencies.rb}, %q{lib/documentalist.rake}, %q{lib/generators/config/config_generator.rb}, %q{lib/generators/config/templates/documentalist.yml}, %q{lib/tasks/documentalist.rake}, %q{rails/config/documentalist.yml.tpl}, %q{rails/init.rb}, %q{rails/initialize_configuration.rb}, %q{test/documentalist_test.rb}, %q{test/fixtures/fixture_001.odt}, %q{test/fixtures/fixture_002.html}, %q{test/net_pbm_test.rb}, %q{test/odf_merge_test.rb}, %q{test/open_office_test.rb}, %q{test/pdf_tools_test.rb}, %q{test/rails_integration_test.rb}, %q{test/test_helper.rb}, %q{test/wkhtmltopdf_test.rb}, %q{Manifest}]
  s.homepage = %q{http://github.com/davout/documentalist}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Documentalist}, %q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{documentalist}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{The smooth document management experience, usable as a Rails gem plugin or standalone in any ruby application}
  s.test_files = [%q{test/documentalist_test.rb}, %q{test/net_pbm_test.rb}, %q{test/odf_merge_test.rb}, %q{test/open_office_test.rb}, %q{test/pdf_tools_test.rb}, %q{test/rails_integration_test.rb}, %q{test/test_helper.rb}, %q{test/wkhtmltopdf_test.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<zip>, [">= 2.0.2"])
      s.add_runtime_dependency(%q<SystemTimer>, [">= 1.2"])
      s.add_development_dependency(%q<flexmock>, [">= 0.8.6"])
    else
      s.add_dependency(%q<zip>, [">= 2.0.2"])
      s.add_dependency(%q<SystemTimer>, [">= 1.2"])
      s.add_dependency(%q<flexmock>, [">= 0.8.6"])
    end
  else
    s.add_dependency(%q<zip>, [">= 2.0.2"])
    s.add_dependency(%q<SystemTimer>, [">= 1.2"])
    s.add_dependency(%q<flexmock>, [">= 0.8.6"])
  end
end
