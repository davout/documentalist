module Documentalist
  module Dependencies
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def check_binary_dependency(binary, tip)
        puts "Checking for presence of #{binary}...  #{`which #{binary}`.empty? ? "Failed, you might want to #{tip}" : "OK"}"
      end

      def check_dependencies
        @bin_dependencies.each { |k,v| check_binary_dependency(k,v) } if @bin_dependencies
      end

      def depends_on_binaries!(h)
        @bin_dependencies = h
      end
    end
  end
end
