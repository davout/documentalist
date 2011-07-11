module Documentalist
  module NetPBM
    extend Documentalist::Dependencies

    depends_on_binaries! "ppmtojpeg" => "install netpbm package"

    def self.convert(file, options)
      system "ppmtojpeg #{file} > #{options[:to]}"
    end
  end
end
