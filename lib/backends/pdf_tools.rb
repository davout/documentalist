module Documentalist
  module PdfTools
    include Documentalist::Dependencies

    depends_on_binaries! "pdftotext" => "install pdftools package"

    def self.convert(origin, options)
      if system("pdftotext #{origin} #{options[:destination]} > /dev/null 2>&1")
        options[:destination]
      else
        raise Documentalist::Error.new("PdfTools failed")
      end
    end
  end
end
