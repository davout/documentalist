require 'erb'
require 'rubygems'
require 'zip/zip'

module Officer
  def self.merge(str, options = {})
    locals = options[:locals]

    if locals and locals.is_a? Hash
      locals.each do |k,v|
        instance_variable_set("@#{k.to_s}".to_sym, v)
      end
    end

    ERB.new(str).result(binding)
  end

  def self.get_contents(odt_file)
    Zip::ZipFile.open(odt_file) { |zip| zip.read("content.xml") }
  end
end  
