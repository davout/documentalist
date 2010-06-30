# Sample Rails configuration file
# Optional settings are :
#  * log_path : Allows you to override the default log file [Rail.root/log/documentalist.log]

development:
  # Python configuration
  python:
    path: /usr/bin/python

  # Java configuration
  java:
    path: /usr/bin/java

  # OpenOffice configuration
  open_office:
    # Path to the OpenOpffice binary
    path: /usr/bin/soffice

    # Select desired bridge between PYOD and JOD
    bridge: JOD

    # Maximum allowed CPU usage before the process is considered stalled
    max_cpu: 80

    # OpenOffice server allowed startup time (seconds)
    max_startup_time: 4

    # OpenOffice server allowed waking up time (between startup and actual processing)
    wakeup_time: 3

    # Conversion tries before giving up
    max_conversion_attempts: 3

    # Maximum allowed time for converting a document
    max_conversion_time: 6

test:
  python:
    path: /usr/bin/python

  java:
    path: /usr/bin/java

  open_office:
    path: /usr/bin/soffice
    bridge: JOD
    max_cpu: 80
    max_startup_time: 4
    wakeup_time: 3
    max_conversion_attempts: 3
    max_conversion_time: 6

production:
  python:
    path: /usr/bin/python

  java:
    path: /usr/bin/java

  open_office:
    path: /usr/bin/soffice
    bridge: JOD
    max_cpu: 80
    max_startup_time: 4
    wakeup_time: 3
    max_conversion_attempts: 3
    max_conversion_time: 6