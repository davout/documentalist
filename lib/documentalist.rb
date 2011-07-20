require 'rubygems'
require 'yaml'
require 'system_timer'
require 'logger'
require 'kconv'
require 'resque'
require 'resque/job_with_status'
require 'active_support/core_ext'


module Documentalist

  BACKENDS = {
    # Find a better pattern to pick backend, this one smells pretty bad
    :WkHtmlToPdf => {[:html, :htm] => :pdf},
    :OpenOffice => {[:odt, :doc, :rtf, :docx, :txt, :wps] => [:odt, :doc, :rtf, :pdf, :txt, :html, :htm, :wps]},
    :NetPBM => {:ppm => [:jpg, :jpeg]},
    :PdfTools => {:pdf => :txt},
  }

  # Finds the relevant server to perform the conversion
  def self.backend_for_conversion(origin, destination)
    origin = origin.to_s.gsub(/.*\./, "").to_sym
    destination = destination.to_s.gsub(/.*\./, "").to_sym

    BACKENDS.map { |b| [send(:const_get, b[0]), b[1]] }.detect do |s, conversions|
      conversions.keys.flatten.include?(origin) and conversions.values.flatten.include?(destination)
    end.to_a.first
  end

  # todo : too much conflicting options
  # Takes all conversion requests and dispatches them appropriately
  # Accepts a file path as first argument followed by a hash and an optional block
  # * _input_ : a stream content
  # * _input_format_ :
  # * _to_format_ : expected format of the ouput file
  # * _to_ : expected location of the ouput file, passed to the block given as last argument
  # * _stream_ : output data format, streamed data are passed to the block given as last argument
  # * _from_format_ : ??
  def self.convert(file=nil, options={})

    if not File.exist?(file)
      raise Documentalist::Error.new("#{file} does not exist !")
    end

    if options[:stream]
      options[:to_format] = options[:stream]
      options[:to] = File.join(Dir.tmpdir, "#{rand(10**9)}.#{options[:to_format]}")
    end

    options[:to_format] ||= File.extname(options[:to]).gsub(/\./, "")
    options[:from_format] ||= File.extname(file).gsub(/\./, "")
    options[:to] ||= file.gsub(/#{"\\" + File.extname(file)}$/, ".#{options[:to_format].to_s}")

    if [:to_format, :from_format, :to].any?{|key| options[key].nil? }
      raise Documentalist::Error.new("No destination, format, or stream format was given")
    end

    backend = backend_for_conversion(options[:from_format].to_sym, options[:to_format].to_sym)

    backend.convert(file, options)

    if options[:stream]
      data = File.read(options[:to])
      FileUtils.rm(options[:to])
      block_given? ? yield(data) : data
    else
      block_given? ? yield(options[:to]) : options[:to]
    end

    #if options[:input] and options[:input_format] and file.nil?
    #  file = File.join(Dir.tmpdir, "#{rand(10**9)}.#{options[:input_format].to_s}")
    #  File.open(file, 'w') { |f| f.write(options[:input]) }
    #end
    #
    #raise Documentalist::Error.new("#{file} does not exist !") unless File.exist?(file)
    #
    #if options[:to_format]
    #  options[:to] = file.gsub(/#{"\\" + File.extname(file)}$/, ".#{options[:to_format].to_s}")
    #elsif options[:to]
    #  options[:to_format] = File.extname(options[:to]).gsub(/\./, "").to_sym
    #elsif options[:stream]
    #  options[:to_format] = options[:stream]
    #  options[:to] = File.join(Dir.tmpdir, "#{rand(10**9)}.#{options[:to_format]}")
    #else
    #  raise Documentalist::Error.new("No destination, format, or stream format was given")
    #end
    #
    #options[:from_format] ||= File.extname(file).gsub(/\./, "").to_sym
    #
    #backend = backend_for_conversion(options[:from_format], options[:to_format])
    #backend.convert(file, options)
    #
    ## TODO : that would fails removing the file since the input parameter gets overridden
    ## we'll live with it for now
    #if options[:input] and options[:input_format] and file.nil?
    #  FileUtils.rm(file)
    #end
    #
    #if options[:stream]
    #  data = File.read(options[:to])
    #  FileUtils.rm(options[:to])
    #  yield(data) if block_given?
    #  data
    #else
    #  yield(options[:to]) if block_given?
    #  options[:to]
    #end
  end

  def self.extract_text(file)
    converted = convert(file, :to_format => :txt)
    
    if converted and File.exist?(converted)
      text = Kconv.toutf8(File.open(converted).read)
      FileUtils.rm(converted)
      block_given? ? yield(text) : text
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
        Documentalist.convert(ppm_image, :to_format => :jpg)
      end
    else
      Documentalist.convert file, :to_format => :html
    end

    image_files = Dir.glob(File.join(temp_dir, "*.{jpg,jpeg,bmp,tif,tiff,gif,png}"))

    block_given? ? yield(image_files) : image_files
  end

  module Config
    def self.extended(base)
      class << base
        attr_accessor :config, :logger
      end
    end

    # Returns a new hash with recursively symbolized keys
    def symbolize(hash)
      hash.each_key do |key|
        hash[key.to_sym] = hash.delete key
        hash[key.to_sym] = symbolize(hash[key.to_sym]) if hash[key.to_sym].is_a?(Hash)
      end
    end

    def load_config!(load_path, env = nil )
      self.config = symbolize YAML::load_file(load_path)
      self.config = config[:default].update(self.config[env.to_sym]) if config[:default] and env
      self.config
    end

    def init(application_path, config_path, env = nil)

      load_config!(config_path, env)

      @logger = Logger.new(File.join(application_path, config[:log_path]))
      @logger.level = Logger.const_get(config[:log_level] ? config[:log_level].upcase : "WARN")

      # Require all backends
      Dir.glob(File.join(File.dirname(__FILE__), 'backends', '*.rb')).each do |backend|
        require backend
      end

      self
    end

  end

  module Dependencies

    def check_binary_dependency(binary, tip)
      puts "Checking for presence of #{binary}...  #{`which #{binary}`.empty? ? "Failed, you might want to #{tip}" : "OK"}"
    end

    def check_dependencies
      @bin_dependencies.each { |k,v| check_binary_dependency(k,v) } if @bin_dependencies
    end

    def depends_on_binaries!(h)
      @bin_dependencies = h
    end

  end

  extend Config

  class Error < RuntimeError; end
end

require File.join(File.dirname(__FILE__),"railtie") if defined?(Rails)