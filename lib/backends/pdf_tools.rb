# To change this template, choose Tools | Templates
# and open the template in the editor.

module Documentalist
  module PdfTools
    def self.convert(origin, options)
      if system("pdftotext #{origin} #{options[:destination]} > /dev/null 2>&1")
        options[:destination]
      else
        raise "PdfTools a echoué"
      end
    end
  end
end
