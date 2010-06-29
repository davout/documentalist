# Initializes a standard configuration file in Rails.root/config/documentalist.yml
unless File.exists?(File.join(RAILS_ROOT , %w{config documentalist.yml}))
  FileUtils.cp(File.join(File.dirname(__FILE__), %w{config documentalist.yml.tpl}), File.join(RAILS_ROOT, %w{config documentalist.yml}))
end


