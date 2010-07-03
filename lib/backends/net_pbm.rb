# To change this template, choose Tools | Templates
# and open the template in the editor.

module Documentalist
  module NetPBM
    include Documentalist::Dependencies

    depends_on_binaries! "ppmtojpeg" => "install netpbm package"

    def self.convert(file, options)
      system "ppmtojpeg #{file} > #{options[:to]}"
    end
  end
end
