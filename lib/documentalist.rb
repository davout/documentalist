require 'rubygems'
require 'yaml'

# Require all backends
Dir.glob(File.join(File.dirname(__FILE__), 'backends', '*.rb')).each do |backend|
  require backend
end

module Documentalist
  @@config = {}

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
  def self.server_for_conversion(origin, destination)
    Servers::CONVERTERS.detect do |s, conversions|
      conversions.keys.flatten.include?(origin) and conversions.values.flatten.include?(destination)
    end.to_a.first
  end

  # Takes all conversion requests and dispatches them appropriately
  def self.convert(file_name, options={})
    raise "#{file_name} does not exist !" unless File.exist?(file_name)

    # Convert to plain text by default
    options[:to] = (options[:to].nil? or options[:to].empty?) ? :txt : options[:to].to_sym

    options[:from] = File.extname file_name

    backend = backend_for_conversion(options[:from], options[:to])
    converted = backend.convert(file_name, options)

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
    temp_dir = File.join(CONVERSIONS_PATH, (Time.new.to_f*100_000).to_i.to_s)
    
    if File.extname(file) == '.pdf'
      temp_file = File.join(temp_dir, File.basename(file))

      system "mkdir #{temp_dir} && cp #{file} #{temp_file}"
      system "cd #{temp_dir} && pdfimages #{temp_file} 'img'"

      Dir.glob(File.join(temp_dir, "*.ppm")).each do |ppm_image|
        Documentalist.convert(ppm_image, :to => :jpeg)
      end
    else
      convert file, :to => :html, :directory => temp_dir
    end

    image_file_names = Dir.glob(File.join(temp_dir, "*.{jpg,jpeg,bmp,tif,tiff,gif,png}"))

    yield(image_file_names) if block_given?
    image_file_names
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

  private

  # Returns a new hash with recursively symbolized keys
  def self.symbolize(hash)
    hash.each_key do |key|
      hash[key.to_sym] = hash.delete key
      hash[key.to_sym] = symbolize(hash[key.to_sym]) if hash[key.to_sym].is_a?(Hash)
    end
  end
end  
