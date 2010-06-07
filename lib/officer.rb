require 'rubygems'
require 'erb'
require 'fileutils'
require 'zip/zip'
require 'open_office/server'

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
    contents = ""
    Zip::ZipFile.open(odt_file) { |zip| contents = zip.read("content.xml") }
    contents.gsub("&lt;%", "<%").gsub("%&gt;", "%>")
  end

  def self.merge_template(template, options = {})
    tmp = Tempfile.new("officer")
    
    tmp.write(merge(get_contents(template), :locals => options[:locals]))
    tmp.close

    FileUtils.cp(template, options[:to]) if options[:to]
    destination = options[:to] || template
      
    Zip::ZipFile.open(destination) do |zip|
      zip.replace("content.xml", tmp.path)
      zip.commit
    end

    tmp.unlink
  end

  def self.convert(from, to)
    OpenOffice::Server.convert(from, :to => to)
  end
end  
