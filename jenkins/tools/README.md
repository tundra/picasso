These are scripts for doing jenkins-related setup. The terminolgy is as follows:

 * A physical machins is not necessarily literally physical, it can be (most likely is) a virtual machine at some level but it's not a vagrant machine we're running.
 * A virtual machine is a vagrant instance we're running.

These are the scripts,

 * `install-master.sh`: Invoked remotedly to install a jenkins master on a physical machine.
 * `install-slave.sh`: Invoked remotely to set a jenkins slave up on a virtual machine. The machine should be running a vagrant image primed using `prime-slave-base-image.sh`.
 * `paper-backup.sh`: Not really jenkins related. Backup the given file as a series of QR codes written as .png files.
 * `prime-slave-base-image.sh`: Prepares an initially clean remote virtual linux machine with the absolute basics required to be a jenkins slave. The result is a machine that can be packaged into a minimal vagrant box, and the remaining dependencies required to run a slave can then be installed using `install-slave.sh`.
 * `run-script-remote.sh`: Runs the given script on a remote machine, virtual or physical.
