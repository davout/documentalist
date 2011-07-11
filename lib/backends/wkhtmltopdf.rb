module Documentalist
  module WkHtmlToPdf
    extend Documentalist::Dependencies

    depends_on_binaries! "wkhtmltopdf" => "install wkhtmltopdf package"

    def self.convert(file, options)
      command = "wkhtmltopdf #{options[:backend_options] and options[:backend_options].join(" ")} #{file} #{options[:to]} > #{Documentalist.config[:log_file]} 2>&1"
      Documentalist.logger.debug("Going to run WkHtmlToPdf backend with command : #{command}")
      system(command)
    end
  end
end
