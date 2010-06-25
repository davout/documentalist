require 'yaml'

module Proselytism
  
  CONFIG = ( YAML::load(File.open( RAILS_ROOT + "/config/proselytism_config.yml")) || {} )[ ENV['RAILS_ENV'] ] || { 'open_office' => {} }

  CONVERSIONS_PATH = CONFIG['conversions_path'].to_s.gsub(/\/*RAILS_ROOT\s*/,RAILS_ROOT)

  LOG_PATH = RAILS_ROOT + "/log/proselytism.log"

  module Servers
    class OpenOffice
      require 'timeout'

      PYOD_CONVERTER_PATH = File.dirname(__FILE__) + '/odconverters/pyodconverter.py'

      JOD_CONVERTER_PATH = File.dirname(__FILE__) + '/odconverters/jodconverter-2.2.2/lib/jodconverter-cli-2.2.2.jar'

      CONFIG['open_office'].each{|key,value| const_set(key.upcase, value)}

      # Converts documents
      def self.convert(origin, options)
        timeout(CONVERSION_TIME_DELAY, :attempts => CONVERSION_TRIES) do
          if BRIDGE == 'JOD'
            system("java -jar #{JOD_CONVERTER_PATH} #{origin} #{options[:destination]}")
          elsif BRIDGE == 'PYOD'
            system("#{PYTHON_PATH} #{PYOD_CONVERTER_PATH} #{origin} #{options[:destination]}")
          end
          self.convert_txt_to_utf8(options[:destination]) if options[:to] == :txt
          options[:destination]
        end
      end

      # HACK pour contourner un comportement �trange d'OpenOffice, normalement les enregistrements
      # se font en UTF-8, mais parfois pour une raison obscure les fichiers texte sont en ISO-8859-1
      # donc on rajoute un test pour re-convertir dans l'encodage qu'on attend
      def self.convert_txt_to_utf8(file_path)
        if `file #{file_path}` =~ /ISO/
          system("iconv --from-code ISO-8859-1 --to-code UTF-8 #{file_path} > tmp_iconv.txt && mv tmp_iconv.txt #{file_path}")
        end
      end
      
      private

      # Is OpenOffice server running?
      def self.running?
        !`pgrep soffice`.blank?
      end

      # Restart if running or start new instance
      def self.restart!
        kill! if running?
        start!
      end

      # Start new instance
      def self.start!
        raise "Already running!" if running?
        system("#{OPEN_OFFICE_PATH} -headless -accept=\"socket,host=127.0.0.1,port=8100\;urp\;\" -nofirststartwizard -nologo -nocrashreport -norestore -nolockcheck -nodefault >> #{LOG_PATH} 2>&1 &")
        begin
           Timeout::timeout(3) do
            while !running?
              print "."
            end
          end
        rescue
          raise "Could not start OpenOffice"
        end

        # OpenOffice needs some time to wake up
        sleep(SERVER_START_DELAY)

        nil
      end

      # Kill running instance
      def self.kill!
        raise "Not running!" unless running?

        begin
          Timeout::timeout(3) do
            while(running?)
              system("pkill -9 office")
            end
          end
        rescue Timeout::Error
          raise "Mayday, mayday ! Could not kill OpenOffice !!"
        ensure
          # Remove user profile
          system("rm -rf ~/openoffice.org*")
        end
      end

      # Is the current instance stuck ?
      def self.stalled?
        if running?
          cpu_usage = `ps -Ao pcpu,pid,comm | grep soffice | grep [#{pids.collect{|pid| '\('+pid.to_s+'\)'}}]`.split(/\n/)
          cpu_usage.any? { |usage| /^\s*\d+/.match(usage)[0].strip.to_i > MAX_CPU }
        end
      end

      # Make sure there will be an available instance
      def self.ensure_available
        start! unless running?
        restart! if stalled?
      end

      # Get OO processes pids
      def self.pids
        `pgrep soffice`.split.map(&:to_i) unless `pgrep soffice`.blank?
      end

      # Run a block with a timeout and retry if the first execution fails
      def self.timeout(max_time = 0, options = {:attempts => 1, :sleep => nil})
        if block_given?
          attempts = options[:attempts] || 1
          begin
            ensure_available
            Timeout::timeout(max_time) do
              yield
            end
          rescue Timeout::Error
            attempts -= 1
            ensure_available 
            sleep(options[:sleep]) if options[:sleep]
            retry unless attempts.zero?
            raise
          end
        end
      end
    end

    class PdfTools
      def self.convert(origin, options)
        if system("pdftotext #{origin} #{options[:destination]} > /dev/null 2>&1")
          options[:destination]
        else
          raise "PdfTools a echoué"
        end
      end
    end

    class NetPBM
    end

    CONVERTERS = {
      OpenOffice => {[:odt, :doc, :rtf, :docx, :txt, :html, :htm, :wps] => [:odt, :doc, :rtf, :pdf, :txt, :html, :htm, :wps]},
      NetPBM => {:ppm => [:jpg, :jpeg]},
      PdfTools => {:pdf => :txt}
    }
  end

  # Converts a document from one format to another
  def self.convert(file_name, options={})
    raise "#{file_name} does not exist !" unless File.exist?(file_name)

    options[:to] = options[:to].blank? ? :txt : options[:to].to_sym
    options[:from] = file_name.match(/[^\.]*$/)[0].to_sym
    options[:directory] ||= CONVERSIONS_PATH.blank? ? File.dirname(file_name) : CONVERSIONS_PATH
    options[:destination] = File.join(options[:directory], File.basename(file_name)).gsub(Regexp.new("#{options[:from]}$"), options[:to].to_s) 
    server = server_for_conversion(options[:from], options[:to])
    converted_file_path = server.convert(file_name, options)
    
    block_given? ? yield(converted_file_path) : converted_file_path
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

