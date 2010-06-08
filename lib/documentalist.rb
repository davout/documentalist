require 'rubygems'
require 'erb'
require 'fileutils'
require 'tmpdir'
require 'zip/zip'
require 'open_office/server'

module Documentalist
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
    # Get template contents
    tmp_contents= Tempfile.new("officer-contents")
    tmp_contents.write(merge(get_contents(template), :locals => options[:locals]))
    tmp_contents.close

    # Copy the template so we can merge the data into the copy
    tmp_merged_template = File.join(Dir.tmpdir, "merged-template-#{rand(10**9)}#{File.extname(template)}")
    FileUtils.cp(template, tmp_merged_template)

    # Stuff the merged contents.xml into the OpenDocument zip
    Zip::ZipFile.open(tmp_merged_template) do |zip|
      zip.replace("content.xml", tmp_contents.path)
      zip.commit
    end

    # Remove the merged contents.xml
    tmp_contents.unlink

    # Manages the converted file depending on the context
    if options[:to]
      if File.extname(options[:to]) == File.extname(template)
        FileUtils.mv(tmp_merged_template, options[:to])
      else
        OpenOffice::Server.convert(tmp_merged_template, options[:to])
        FileUtils.rm(tmp_merged_template)
      end
    else
      FileUtils.rm(template)
      FileUtils.mv(tmp_merged_template, template)
    end
  end

  def self.convert(from, to)
    OpenOffice::Server.convert(from, :to => to)
  end
end  
