# Workaround a problem with script/plugin and http-based repos.
# See http://dev.rubyonrails.org/ticket/8189
Dir.chdir(Dir.getwd.sub(/vendor.*/, '')) do

##
## Copy over asset files (javascript/css/images) from the plugin directory to public/
##

  def copy_files(source_path, destination_path, directory, options={})
    source = File.join(directory, source_path)
    destination = File.join(Rails.root, destination_path)
    FileUtils.mkdir(destination) unless File.exist?(destination)
    FileUtils.cp_r(Dir.glob(source +'/*.*'), destination, options)
  end
  
  unless File.exists?( File.join(Rails.root,"config/proselytism_config.yml"))
    copy_files("/config", "/config", File.dirname(__FILE__))
  end

end