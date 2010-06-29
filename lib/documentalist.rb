require 'rubygems'

# Require all backends
Dir.glob(File.join(File.dirname(__FILE__), 'backends', '*.rb')).each do |backend|
  require backend
end

module Documentalist
  def self.config
    @@config || {}
  end

  def self.config=(hash)
    # We want to symbolize keys ourselves since we're not depending on Active Support
    @@config = symbolize hash
  end

  # Takes all conversion requests and dispatches them appropriately
  def self.convert(file_name, options={})
    raise "#{file_name} does not exist !" unless File.exist?(file_name)

    # Convert to plain text by default
    options[:to] = options[:to].blank? ? :txt : options[:to].to_sym

    options[:from] = File.extname file_name

    backend = backend_for_conversion(options[:from], options[:to])
    converted = backend.convert(file_name, options)

    yield(converted) if block_given?
    converted
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
