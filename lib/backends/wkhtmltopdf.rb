module Documentalist
  module WkHtmlToPdf
    include Documentalist::Dependencies

    depends_on_binaries! "wkhtmltopdf" => "install wkhtmltopdf package"

    def self.convert(file, options)
      command = "wkhtmltopdf -q #{file} #{options[:to]}"
      Documentalist.logger.debug("Going to run WkHtmlToPdf backend with command : #{command}")
      system(command)
    end
  end
end
