 * Create a new virtualbox vm. Make sure it's at least as powerful as the OS's minimal requirements, typically you can go below virtualbox's suggestions. The name should be something like the full os name (ie. "Ubuntu 14.04.2 Server i386").
 * Power up. Mount the OS install image.
 * Install the OS. Wherever possible use the vanilla configuration.
 * The user account should be "vagrant", password "vagrant".
 * No need for disk encryption.
 * Only install the absolute bare minimum. If you can not install a gui then that's ideal.
 * After installing, ensure there's an ssh server installed (maybe install openssh-server).
 * Maybe make a snapshot in case something goes wrong in the following steps?
 * Shut down the machine. Manually forward port 22 to some arbitrary port on the host so we can connect to it from elsewhere.
 * From a host that has access to the vagrant private key, run `picasso/jenkins/tools/prime-slave-base-image.sh`.
 
