require 'timeout'
require 'tmpdir'

module OpenOffice
  module Server
    # Path to the Python executable
    PYTHON_PATH = "/usr/bin/python"

    # Server can convert from the following file formats
    CONVERT_FROM = [:odt, :doc, :rtf, :docx, :txt, :html, :htm, :wps]

    # To the following formats
    CONVERT_TO = [:odt, :doc, :rtf, :pdf, :txt, :html, :htm, :wps]

    # Python conversion script path
    PY_OD_CONVERTER = File.join(File.dirname(__FILE__), "../DocumentConverter.py")

    # Maximum allowed CPU usage for an OpenOffice process
    MAX_CPU = 80

    # Server start grace time
    SERVER_START_DELAY = 4

    # Log file
    LOG_FILE = Object.const_defined?(:RAILS_ROOT) ? File.join(RAILS_ROOT, "log", "openoffice.log") : ""

    def self.convert(origin, options = {:to => :txt})
      if options and options[:to]
        raise "#{origin} does not exist !" unless File.exist?(origin)
        ensure_available

        if options[:to].is_a? Symbol
          destination = "#{origin.gsub(/[^\.]*$/, "")}#{options[:to].to_s}"
        elsif options[:to].is_a? String
          destination = options[:to]
        else
          raise "Can't convert #{origin} to #{options[:to]}"
        end

        timeout(10, :attempts => 2) do
          system("#{PYTHON_PATH} #{PY_OD_CONVERTER} #{origin} #{destination} > /dev/null 2>&1")

          # HACK : sometimes text files get saved in ISO-8859-1 instead of regular UTF-8, so we force
          # a conversion if it's the case
          if `file #{destination}` =~ /ISO/ and destination =~ /\.txt$/
            temp_file = File.join(Dir.tmpdir, "tmp_iconv_#{rand(10**9)}.txt")
            system("iconv --from-code ISO-8859-1 --to-code UTF-8 #{destination} >  && #{temp_file} mv #{temp_file} #{destination}")
          end
        end

        destination
      end
    end

    private
    # Is OpenOffice server running?
    def self.running?
      !`pgrep office`.empty?
    end

    # Restart if running or start new instance
    def self.restart!
      kill! if running?
      start!
    end

    # Start new instance
    def self.start!
      raise "Already running!" if running?
      system("/usr/bin/soffice -headless -accept=\"socket,host=127.0.0.1,port=8100;urp;\" -nofirststartwizard -nologo -nocrashreport -norestore -nolockcheck -nodefault #{">>" unless LOG_FILE.empty?} #{LOG_FILE} 2>&1 &")

      begin
        timeout(2) do
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
        timeout(3, :attempts => 2) do
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
        cpu_usage = `ps -Ao pcpu,pid,cmd | grep office`
        cpu_usage = cpu_usage.split(/\n/).select{|line| /#{pids.join("|")}/.match(line) }

        cpu_usage.any?{|usage| /^\s*\d+/.match(usage)[0].strip.to_i > MAX_CPU}
      end
    end

    # Make sure there will be an available instance
    def self.ensure_available
      start! unless running?
      restart! if stalled?
    end

    # Get OO processes pids
    def self.pids
      `pgrep office`.split.map{|pid| pid.to_i } unless `pgrep office`.empty?
    end

    # Run a block with a timeout and retry if the first execution fails
    def self.timeout(max_time = 0, options = {:attempts => 1, :sleep => nil})
      if block_given?
        attempts = options[:attempts] || 1
        begin
          Timeout::timeout(max_time) do
            yield
          end
        rescue Timeout::Error
          attempts -= 1
          sleep(options[:sleep]) if options[:sleep]
          retry unless attempts.zero?
          raise
        end
      end
    end

    def self.convertible?(origin, destination)
      CONVERT_FROM.include?(File.extname(origin)) && CONVERT_TO.include?(File.extname(destination))
    end
  end
end
