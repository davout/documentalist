module Documentalist
  module OpenOffice
    extend Documentalist::Dependencies

    depends_on_binaries! "ps" => "use Documentalist in a Posix compliant OS",
      Documentalist.config[:open_office][:path] || 'open-office' => "install Open Office and correctly configure the path to its binary",
      "pkill" => "install pkill binary and make it available through the PATH",
      "pgrep" => "install pgrep binary and make it available through the PATH",
      "java" => "install java",
      "python" => "install python",
      "file" => "install file binary",
      "iconv" => "install iconv binary"

    # Converts documents
    def self.convert(origin, options)
      Documentalist.logger.debug("Going to convert #{origin} to #{options[:to]}")

      # See how to make OpenOffice startup as smooth as possible and not on first conversion
      # OO auto-start option if in Rails app ?
      Server.ensure_available

      # TODO : manage multi OO instances : http://code.google.com/p/jodconverter/wiki/GettingStarted

      Documentalist.timeout(Documentalist.config[:open_office][:max_conversion_time], :attempts => Documentalist.config[:open_office][:max_conversion_attempts]) do
        if Documentalist.config[:open_office][:bridge] == 'JOD'
          command = "#{Documentalist.config[:java][:path]} -jar #{File.join(File.dirname(__FILE__), %w{open_office bridges jodconverter-2.2.2 lib jodconverter-cli-2.2.2.jar})} #{origin} #{options[:to]}"          
        elsif Documentalist.config[:open_office][:bridge] == 'PYOD'
          command = "#{Documentalist.config[:python][:path]} #{File.join(File.dirname(__FILE__), %w{open_office bridges pyodconverter.py})} #{origin} #{options[:to]}"
        end

        if Documentalist.config[:log_file] and !Documentalist.config[:log_file].empty?
          command += " >> #{Documentalist.config[:log_file]} 2>&1"
        end

        Documentalist.logger.debug("Going to run #{Documentalist.config[:open_office][:bridge]} bridge with command -- #{command}")
        system(command)

        self.convert_txt_to_utf8(options[:to]) if options[:to_format] == :txt
        
        options[:to]
      end
    end

    # HACK : convert ISO-8859-1 files back to UTF-8 when OpenOffice messes up and
    # outputs the wrong encoding
    def self.convert_txt_to_utf8(file_path)
      if `file #{file_path}` =~ /ISO/
        system("iconv --from-code ISO-8859-1 --to-code UTF-8 #{file_path} > tmp_iconv.txt && mv tmp_iconv.txt #{file_path}")
      end
    end

    module Server
      # Is OpenOffice server running?
      def self.running?
        !`pgrep soffice`.empty?
      end

      # Restart if running or start new instance
      def self.restart!
        Documentalist.logger.debug("Restarting OpenOffice instance...")
        (kill! if running?) and start!
        Documentalist.logger.debug("...done !")
      end

      # Start new instance
      def self.start!
        Documentalist.logger.debug("Starting OpenOffice instance...")
        raise "Already running!" if running?

        command_line = "#{Documentalist.config[:open_office][:path]} -headless -accept=\"socket,host=127.0.0.1,port=8100\;urp\;\" -nofirststartwizard -nologo -nocrashreport -norestore -nolockcheck -nodefault"
        command_line << " >> #{Documentalist.config[:log_file]} 2>&1"
        command_line << " &"

        system(command_line)
        
        begin
          Documentalist.timeout(Documentalist.config[:open_office][:max_startup_time]) do
            while !running?
              # Do nothing
            end
          end
        rescue Timeout::Error
          raise "OpenOffice didn't start fast enough, you might want to increase the max_startup_time value or check your OpenOffice configuration"
        end

        # OpenOffice needs some time to fully wake up
        sleep(Documentalist.config[:open_office][:wakeup_time])
        nil
      end

      # Kill running instance
      def self.kill!
        raise "Not running!" unless running?

        begin
          Documentalist.timeout(3) do
            while(running?)
              system("pkill -9 office")
            end
          end
        rescue Timeout::Error
          raise "Mayday, mayday ! Could not kill OpenOffice !!"
        ensure
          # Remove user profile
          system("rm -rf ~/openoffice.org*")
        end
      end

      # Is the current instance stuck ?
      def self.stalled?
        if running?
          cpu_usage = `ps -Ao pcpu,pid,comm | grep soffice | grep [#{pids.collect{|pid| '\('+pid.to_s+'\)'}}]`.split(/\n/)
          cpu_usage.any? { |usage| /^\s*\d+/.match(usage)[0].strip.to_i > Documentalist.config[:open_office][:max_cpu] }
        end
      end

      # Make sure there will be an available instance
      def self.ensure_available
        start! unless running?
        restart! if stalled?
      end

      # Get OO processes pids
      def self.pids
        `pgrep soffice`.split.map(&:to_i) unless `pgrep soffice`.empty?
      end
    end
  end
end
