## Creating a linux base box

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

If all this works, deliver the box wherever it's needed. Remember, the box file should not contain any secrets of any kind because if they don't that makes them easier to handle, less to worry about, and before using an instance there'll be an install step for that particular concrete instance where secrets can be installed.

## Resizing a linux disk

The disks are typically stored as VMDK and can't be resized. Instead, clone the disk into a VDI image using the virtual media manager, resize it using for instance `VBoxManage modifyhd <path> --resize 8192`, remove the previous disk image from the VM, remove it from the virtual media manger's list, then attach the cloned and resized disk.

After resizing the disk you need to repartition it so the vm gets access to the new space. This is kind of a pain. One approach that has worked has been to mount an install disk in the CD drive, boot the machine and enter the rescue flow, aborting the process and jumping to the partition step.
