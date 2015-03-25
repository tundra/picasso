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
 * Shut the machine down. Package it into a vagrant box using `vagrant package --base (name)`.
 * If this is a new type of machine, add an entry for it in `picasso/vagrant/linux`.
 * Try running the new slave. It should start up without errors.
 * Try running `picasso/jenkins/tools/install-slave.sh` against your new vagrant-run slave. The slave should start up and attach to the jenkins server without errors.

If all this works, deliver the box wherever it's needed. Remember, the box file contains some slightly secret information, the jenkins slave id, and has no protection of any kind. So don't leave it just lying around in a publicly visible place. If it's a massive hassle to keep the base boxes secret don't not keep them secret. The boxes are almost free of secrets and can be made completely free of them so if it's necessary let's take the time to do that instead.
