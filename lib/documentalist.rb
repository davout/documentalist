require 'rubygems'
require 'yaml'
require 'system_timer'
require 'logger'

# Require all backends
Dir.glob(File.join(File.dirname(__FILE__), 'backends', '*.rb')).each do |backend|
  require backend
end

module Documentalist
  @@config = {}
  @@logger = nil

  def self.config
    default_config! unless config?
    @@config
  end

  def self.config=(hash)
    # We want to symbolize keys ourselves since we're not depending on Active Support
    @@config = symbolize hash
  end

  def self.config?
    @@config != {}
  end

  def self.default_config!
    config_from_yaml! File.join(File.dirname(__FILE__), %w{.. config default.yml})
  end

  def self.config_from_yaml!(file, options = {})
    self.config = YAML::load(File.open(file))
    self.config = config[options[:section].to_sym] if options[:section]
  end

  BACKENDS = {
    OpenOffice => {[:odt, :doc, :rtf, :docx, :txt, :html, :htm, :wps] => [:odt, :doc, :rtf, :pdf, :txt, :html, :htm, :wps]},
    NetPBM => {:ppm => [:jpg, :jpeg]},
    PdfTools => {:pdf => :txt},
    
    # Find a better pattern to pick backend, this one smells pretty bad
    # WkHTML2PDF => {[:html, :htm] => :pdf}
  }

  # Finds the relevant server to perform the conversion
  def self.backend_for_conversion(origin, destination)
    origin = origin.to_s.gsub(/.*\./, "").to_sym
    destination = destination.to_s.gsub(/.*\./, "").to_sym

    BACKENDS.detect do |s, conversions|
      conversions.keys.flatten.include?(origin) and conversions.values.flatten.include?(destination)
    end.to_a.first
  end

  # Takes all conversion requests and dispatches them appropriately
  def self.convert(file, options={})
    raise "#{file} does not exist !" unless File.exist?(file)

    unless options[:to] or options[:to_format]
      raise Documentalist::Error.new("No destination or format was given")
    end
    
    # Convert to plain text by default
    options[:to_format] = options[:to_format] ? options[:to_format].to_sym : :txt

    unless options[:to]
      options[:to] = file.gsub(/#{"\\" + File.extname(file)}$/, ".#{options[:to_format].to_s}")
    end

    options[:from_format] = File.extname(file).gsub(/\./, "").to_sym

    backend = backend_for_conversion(options[:from_format], options[:to_format])
    converted = backend.convert(file, options)

    yield(converted) if block_given?
    converted
  end

  def self.extract_text(file)
    converted = convert(file, :to => :txt)
    if converted and File.exist?(converted)
      text = File.open(converted).read.toutf8
      FileUtils.rm(converted)

      yield(extracted_text) if block_given?
      text
    end
  end

  def self.extract_images(file)
    temp_dir = File.join(Dir.tmpdir, rand(10**9).to_s)
    
    if File.extname(file) == '.pdf'
      temp_file = File.join(temp_dir, File.basename(file))

      FileUtils.mkdir_p temp_dir
      FileUtils.cp file, temp_file
      
      system "pdfimages #{temp_file} '#{File.join(temp_dir, "img")}'"

      Dir.glob(File.join(temp_dir, "*.ppm")).each do |ppm_image|
        #raise ppm_image
        Documentalist.convert(ppm_image, :to_format => :jpeg)
      end
    else
      Documentalist.convert file, :to_format => :html
    end

    image_files = Dir.glob(File.join(temp_dir, "*.{jpg,jpeg,bmp,tif,tiff,gif,png}"))

    yield(image_files) if block_given?
    image_files
  end

  # Runs a block with a system-enforced timeout and optionally retry with an
  # optional sleep between attempts of running the given block.
  # All times are in seconds.
  def self.timeout(time_limit = 0, options = {:attempts => 1, :sleep => nil})
    if block_given?
      attempts = options[:attempts] || 1
      begin
        SystemTimer.timeout time_limit do
          yield
        end
      rescue Timeout::Error
        attempts -= 1
        sleep(options[:sleep]) if options[:sleep]
        retry unless attempts.zero?
        raise
      end
    end
  end

  def self.logger
    unless @@logger
      @@logger = Logger.new(Documentalist.config[:log_file])
      @@logger.level = Logger.const_get(config[:log_level] ? config[:log_level].upcase : "WARN")
    end

    @@logger
  end

  # Returns a new hash with recursively symbolized keys
  def self.symbolize(hash)
    hash.each_key do |key|
      hash[key.to_sym] = hash.delete key
      hash[key.to_sym] = symbolize(hash[key.to_sym]) if hash[key.to_sym].is_a?(Hash)
    end
  end

  class Error < RuntimeError; end
end  
