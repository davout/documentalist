module Documentalist
  module OpenOffice
    # Converts documents
    def self.convert(origin, options)
      # See how to make OpenOffice startup as smooth as possible and not on first conversion
      # OO auto-start option if in Rails app ?
      Server.ensure_available

      Documentalist.timeout(CONVERSION_TIME_DELAY, :attempts => CONVERSION_TRIES) do
        if BRIDGE == 'JOD'
          system("java -jar #{JOD_CONVERTER_PATH} #{origin} #{options[:destination]}")
        elsif BRIDGE == 'PYOD'
          system("#{PYTHON_PATH} #{PYOD_CONVERTER_PATH} #{origin} #{options[:destination]}")
        end
        self.convert_txt_to_utf8(options[:destination]) if options[:to] == :txt
        options[:destination]
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
        (kill! if running?) and start!
      end

      # Start new instance
      def self.start!
        raise "Already running!" if running?

        system("#{Documentalist.config[:open_office][:path]} -headless -accept=\"socket,host=127.0.0.1,port=8100\;urp\;\" -nofirststartwizard -nologo -nocrashreport -norestore -nolockcheck -nodefault >> #{LOG_PATH} 2>&1 &")
        
        begin
          Documentalist.timeout(3) do
            while !running?
              print "."
            end
          end
        rescue
          raise "Could not start OpenOffice"
        end

        # OpenOffice needs some time to wake up
        sleep(SERVER_START_DELAY)
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
          cpu_usage.any? { |usage| /^\s*\d+/.match(usage)[0].strip.to_i > MAX_CPU }
        end
      end

      # Make sure there will be an available instance
      def self.ensure_available
        start! unless running?
        restart! if stalled?
      end

      # Get OO processes pids
      def self.pids
        `pgrep soffice`.split.map(&:to_i) unless `pgrep soffice`.blank?
      end
    end
  end
end
