module Documentalist
  module PdfTools
    extend Documentalist::Dependencies

    depends_on_binaries! "pdftotext" => "install pdftools package"

    def self.convert(origin, options)
      if system("pdftotext #{origin} #{options[:to]} -enc UTF-8 > #{Documentalist.config[:log_path]} 2>&1")
        options[:to]
      else
        raise Documentalist::Error.new("PdfTools failed")
      end
    end
  end
end
