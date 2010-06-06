require 'erb'

module Officer
  def self.merge(str, data = {})
    ERB.new(str).result
  end
end  
