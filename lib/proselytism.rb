require 'yaml'
require 'system_timer'

module Documentalist
  
  CONFIG = ( YAML::load(File.open( File.join(RAILS_ROOT, "config", "documentalist.yml")) || {} )[ ENV['RAILS_ENV'] ] || { 'open_office' => {} }

  CONVERSIONS_PATH = CONFIG['conversions_path'].to_s.gsub(/\/*RAILS_ROOT\s*/, RAILS_ROOT)

  LOG_PATH = RAILS_ROOT + "/log/documentalist.log"

  module Servers
    class OpenOffice
      PYOD_CONVERTER_PATH = File.dirname(__FILE__) + '/odconverters/pyodconverter.py'

      JOD_CONVERTER_PATH = File.dirname(__FILE__) + '/odconverters/jodconverter-2.2.2/lib/jodconverter-cli-2.2.2.jar'

      CONFIG['open_office'].each{|key,value| const_set(key.upcase, value)}

      # Converts documents
      def self.convert(origin, options)
        Documentalist.timeout(CONVERSION_TIME_DELAY, :attempts => CONVERSION_TRIES) do
          if BRIDGE == 'JOD'
            system("java -jar #{JOD_CONVERTER_PATH} #{origin} #{options[:destination]}")
          elsif BRIDGE == 'PYOD'
            system("#{PYTHON_PATH} #{PYOD_CONVERTER_PATH} #{origin} #{options[:destination]}")
          end
          self.convert_txt_to_utf8(options[:destination]) if options[:to] == :txt
          options[:destination]
        end
      end

      # HACK pour contourner un comportement étrange d'OpenOffice, normalement les enregistrements
      # se font en UTF-8, mais parfois pour une raison obscure les fichiers texte sont en ISO-8859-1
      # donc on rajoute un test pour re-convertir dans l'encodage qu'on attend
      def self.convert_txt_to_utf8(file_path)
        if `file #{file_path}` =~ /ISO/
          system("iconv --from-code ISO-8859-1 --to-code UTF-8 #{file_path} > tmp_iconv.txt && mv tmp_iconv.txt #{file_path}")
        end
      end
      


  


    end

    CONVERTERS = {
      OpenOffice => {[:odt, :doc, :rtf, :docx, :txt, :html, :htm, :wps] => [:odt, :doc, :rtf, :pdf, :txt, :html, :htm, :wps]},
      NetPBM => {:ppm => [:jpg, :jpeg]},
      PdfTools => {:pdf => :txt}
    }
  end
 
  # Finds the relevant server to perform the conversion
  def self.server_for_conversion(origin, destination)
    Servers::CONVERTERS.detect do |s, conversions|
      conversions.keys.flatten.include?(origin) and conversions.values.flatten.include?(destination)
    end.to_a.first
  end

  def self.extract_images(file_path)
    temp_dir = File.join(CONVERSIONS_PATH, (Time.new.to_f*100_000).to_i.to_s)
    if File.extname(file_path) == '.pdf'
      temp_file = File.join(temp_dir, File.basename(file_path))
      system "mkdir #{temp_dir} && cp #{file_path} #{temp_file}" 
      system "cd #{temp_dir} && pdfimages #{temp_file} 'img'"
      Dir.glob(File.join(temp_dir, "*.ppm")).each do |ppm_image|
        system("cd #{temp_dir} && ppmtojpeg #{ppm_image} > #{ppm_image.gsub(/ppm$/, "jpg")}")
      end
    else
      convert(file_path, :to => :html, :directory => temp_dir)
    end
    image_file_names = Dir.glob(File.join(temp_dir, "*.{jpg,jpeg,bmp,tif,tiff,gif,png}"))

    block_given? ? yield(image_file_names) : image_file_names 
  end

  def self.extract_text(file_path)
    converted_file = convert(file_path, :to => :txt)
    if converted_file and File.exist?(converted_file)
      extracted_text = File.open(converted_file).read.toutf8
      FileUtils.rm_f(converted_file)
      block_given? ? yield(extracted_text) : extracted_text 
    end
  end
end

