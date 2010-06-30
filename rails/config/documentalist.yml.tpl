# Sample Rails configuration file
# Optional settings are :
#  * log_path : Allows you to override the default log file [Rail.root/log/documentalist.log]

development:
  open_office:
    # Path to the puthon binary
    python_path: /usr/bin/python

    # Path to the OpenOpffice binary
    open_office_path: /usr/bin/soffice

    # Select desired bridge between PYOD and JOD
    bridge: JOD

    # Maximum allowed CPU usage before the process is considered stalled
    max_cpu: 80

    # OpenOffice server allowed startup time (seconds)
    server_start_delay: 5

    # Conversion tries before giving up
    conversion_tries: 3

    # Maximum allowed time for converting a document
    conversion_time_delay: 6

test:
  open_office:
    python_path: /usr/bin/python
    open_office_path: /usr/bin/soffice
    bridge: JOD
    max_cpu: 80
    server_start_delay: 5
    conversion_tries: 3
    conversion_time_delay: 6

production:
  open_office:
    python_path: /usr/bin/python
    open_office_path: /usr/bin/soffice
    bridge: JOD
    max_cpu: 80
    server_start_delay: 5
    conversion_tries: 3
    conversion_time_delay: 6
