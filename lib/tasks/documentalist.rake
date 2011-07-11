namespace :documentalist do
  desc "Checks that the required dependencies are met for the different backends"
  task :check_backends => :environment do
    puts "Checking backends system dependencies"
    Documentalist.constants.each do |backend|
      backend = Documentalist.const_get backend.to_sym
      if backend.respond_to? :check_dependencies
        puts "Checking dependencies for #{backend.to_s}"
        backend.send :check_dependencies
      end
    end
  end

end