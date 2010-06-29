module Documentalist
  module OpenOffice
    module Server
      # Is OpenOffice server running?
      def self.running?
        !`pgrep soffice`.blank?
      end

      # Restart if running or start new instance
      def self.restart!
        (kill! if running?) and start!
      end

      # Start new instance
      def self.start!
        raise "Already running!" if running?

        system("#{OPEN_OFFICE_PATH} -headless -accept=\"socket,host=127.0.0.1,port=8100\;urp\;\" -nofirststartwizard -nologo -nocrashreport -norestore -nolockcheck -nodefault >> #{LOG_PATH} 2>&1 &")
        
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
