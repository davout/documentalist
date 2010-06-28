unless File.exists?(File.join(RAILS_ROOT , %w{config documentalist.yml}))
  FileUtils.cp(File.join(File.dirname(__FILE__), %w{config documentalist.yml}), File.join(RAILS_ROOT, "config"))
end
