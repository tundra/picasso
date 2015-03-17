REM sleep to give the network share time to become available.
timeout 60

REM delegate to the real runner.
C:\platform\windows\run-jenkins-slave.bat 1> C:\Users\vagrant\Documents\jenkins\jenkins-slave.out 2> C:\Users\vagrant\Documents\jenkins\jenkins-slave.err
