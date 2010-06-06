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
    merged = merge(get_contents(odt_file), :locals => options[:locals])
    File.open("/tmp/officer.tmp", 'w') {|f| f.write(merged) }
    if options[:to]
      system("cp #{template} #{options[:to]}")
    end

    destination = options[:to] || template

    Zip::ZipFile.open(odt_file) { |zip| zip.add("content.xml", destination) }
  end
end  
