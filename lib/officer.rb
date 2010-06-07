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
    contents = ""
    Zip::ZipFile.open(odt_file) { |zip| contents = zip.read("content.xml") }
    contents.gsub("&lt;%", "<%").gsub("%&gt;", "%>")
  end

  def self.merge_template(template, options = {})
    tmp = Tempfile.new("officer")
    
    tmp.write(merge(get_contents(template), :locals => options[:locals]))
    tmp.close

    File.copy(template, options[:to]) if options[:to]
    destination = options[:to] || template
      
    Zip::ZipFile.open(destination) do |zip|
      zip.replace("content.xml", tmp.path)
      zip.commit
    end

    tmp.unlink
  end
end  
