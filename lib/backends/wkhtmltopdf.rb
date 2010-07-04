module Documentalist
  module WkHtmlToPdf
    include Documentalist::Dependencies

    depends_on_binaries! "wkhtmltopdf" => "install wkhtmltopdf package"

    def self.convert(file, options)
      system "wkhtmltopdf -q #{file} #{options[:to]}"
    end
  end
end
