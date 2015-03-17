### Creating a windows 7 32-bit base box.

This procedure has been followed successfully on ubuntu 13 x64. There's no guarantee that it won't randomly be broken by some dependency.

Before using this make sure that you have a license key that is valid for this use.

 1. Download the official windows 7 professional 32-bit [iso](http://msft.digitalrivercontent.net/win/X17-59183.iso).

 2. Create a new windows 7 virtual box vm called "Windows 7 32-bit Professional x86 English" (or whatever appropriately describes the vm -- this is the name I'll use below). Make the clipboard bidirectional.

 3. Start it and boot from the downloaded iso. Install windows fresh. Enter your license key at the appropriate time. Create user vagrant with password vagrant.

 4. Once the install is complete you typically want to take a snapshot of the machine state.

 5. Install virtual box guest additions (remember to go to the mounted drive and run the installer).

 6. Disable UAC ([microsoft howto](http://windows.microsoft.com/en-us/windows7/turn-user-account-control-on-or-off)).

 7. Enable the administrator account by running *Computer Management*, under *Local Users and Groups* selecting `Administrator`, unchecking `Account is disabled`, right-clicking and setting the password to `admin`. Close the window.

 8. We're now going to configure WinRM. Open a command prompt. Become the administrator by doing

         runas /user:Administrator cmd

    and entering the password. Then run,

         winrm quickconfig -q
         winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
         winrm set winrm/config @{MaxTimeoutms="1800000"}
         winrm set winrm/config/service @{AllowUnencrypted="true"}
         winrm set winrm/config/service/auth @{Basic="true"}
         sc config WinRM start= auto
    
    At this point the image should be set up such that it can be run with `vagrant up`, though `vagrant ssh` is not going to work yet. Depending on what you'll be using the image for the next steps are optional.
    
## FreeSSH for `vagrant ssh`

 9. Install [FreeSSHd](http://www.freesshd.com/). Create keys. Run it as a system service.

 10. Run the FreeSSHd link on the desktop. This will put a settings icon in the dock area at the bottom right.

 11. Add user `vagrant` with *Public key (SSH only)* authorization and allow *Shell*.

 12. Download the unsafe [public key](https://github.com/mitchellh/vagrant/blob/master/keys/vagrant.pub) and save it as `vagrant` (no file extension) in `C:\\Program Files\\freeSSHd`. Ensure that the file has no `.txt` extension, sometimes it's there but not shown in the UI.

 13. Under `Allow program to communicate through Windows Firewall` allow freeSSHd through.

 14. Use explorer to navigate to the network. Turn on network discovery and file sharing (it'll ask). If it doesn't ask go to the network and sharing center.

 15. Restart such that the new freeSSHd settings take effect.

At this point the VM should be set up appropriately for it to work with vagrant and particularly `vagrant ssh`. To test it you can try creating a vagrant box,

         vagrant package --base "Windows 7 32-bit Professional x86 English" --output win7-32.box

Remember to shut down the machine first. When you do `vagrant ssh` it shouldn't ask for password but sometimes does; it's unclear why that is.

## Development environment

 16. Install the free visual C++ express (typically 2010). A good place to look for it is [here](http://www.visualstudio.com/downloads/download-visual-studio-vs). You may have to install chrome to be able to download it from the website (wut?!?).

 17. Install [git](http://git-scm.com/download/win). Use `Run Git from the Windows Command Prompt` and use the recommended line ending style.

 18. Install [java](https://www.java.com/en/download/). Remember to not install the bundled malware.

 19. Install [python 2.7](https://www.python.org/downloads/) for all users. Add the python bindir (typically `C:\Python27`) and the scriptdir (typically `C:\Python27\Scripts`) to the system `Path` environment variable.

 20. Install [setuptools](https://pypi.python.org/pypi/setuptools).

## Jenkins slave

 19. Go to the jenkins master (for instance `http://aa00:8080`), under configure nodes download the appropriate `slave.jar` to `C:\Users\vagrant\Documents\jenkins`.

 20. Mount the `platform` codebase as a transient network share using `Shared Folders` in the host's virtualbox UI.
 
 21. Start the `Task Scheduler` program on the windows VM. Import `windows/JenkinsSlaveTask.xml` from the `platform` codebase which is now available as a network share. The task won't work until it's run under vagrant but that's fine, that's when we need it.

 22. Copy `windows/start-jenkins-slave.bat` (*not* `run-jenkins-slave.bat`) to `C:\Users\vagrant\Documents\jenkins`.


## Workspace

 17. Open a command prompt and do,

         mkdir C:\Users\Vagrant\Documents\Workspace
         cd C:\Users\Vagrant\Documents\Workspace
         mklink neutrino \\VBOXSVR\neutrino

     The neutrino share won't exist yet, vagrant adds that, but you can still create the symlink.

 18. Optionally create a devel script. SSH'ing into the machine lands you in the system directory (`C:\Windows\system32`) with a plain environment. If you create a batch file there to set up your environment and goes to the workspace you don't have to do it every time. One devel script I've been using looks like this (`C:\Windows\system32\devel.bat`):

         @echo off
         call "C:\Program Files\Microsoft Visual Studio 10.0\VC\bin\vcvars32.bat"
         cd "C:\Users\Vagrant\Documents\Workspace"
 
 19. Once you've set up the environment you can create the final vagrant box using the same command you used for testing. Remember to delete the previous box file and unregister the box from vagrant using

         rm win7-32.box
         vagrant box remove win7-32 virtualbox
