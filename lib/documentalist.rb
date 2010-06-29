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

  private

  # Returns a new hash with recursively symbolized keys
  def self.symbolize(hash)
    hash.each_key do |key|
      hash[key.to_sym] = hash.delete key
      hash[key.to_sym] = symbolize(hash[key.to_sym]) if hash[key.to_sym].is_a?(Hash)
    end
  end
end  
