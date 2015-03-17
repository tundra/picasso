### Creating a vagrant base box

This procedure has been followed successfully on ubuntu 13 x64. There's no guarantee that it won't randomly be broken by some dependency.

Also note that the IE test images are covered by restrictive license terms. Make sure that you're aware of how you can and can't use the resulting box. This image is for **evaluation purposes only**.

 1. Download the IE10 test image for windows 7 from [modern.ie](http://www.modern.ie/en-us/virtualization-tools#downloads). This will give you a set of compressed files.

 2. Unpack the compressed files by executing the `.sfx` file. This may require you to do

        sudo apt-get install libc6-i386
        sudo apt-get install libstdc++6:i386
        chmod a+x IE10.Win7.For.LinuxVirtualBox.part1.sfx

    This will give you a new file, `IE10 - Win7.ova`.

 3. Use *Import Virtual Appliance* in VirtualBox to import the `.ova`. Probably reinitialize MAC addresses.

 4. Start the new VM through the VirtualBox UI. Install guest additions. The following steps all take place within the VM.

 5. Use *Manage Accounts* under *User Accounts* to create a new user, `vagrant` with password `vagrant`. The new account should be an administrator.

 6. Enable password login. Open a command prompt. Run

        control userpasswords2

    Check to enter user name and password. Uncheck *require Ctrl+Alt+Delete*.

 7. Log out of `IEUser`. Log in as `vagrant`.

 8. Disable UAC ([microsoft howto](http://windows.microsoft.com/en-us/windows7/turn-user-account-control-on-or-off)).

 9. Go to the network and sharing center. Change the active network from being public to being work.

 10. Enable the administrator account by running *Computer Management*, under *Local Users and Groups* selecting `Administrator`, unchecking `Account is disabled`, right-clicking and setting the password to `admin`. Close the window.

 11. We're now going to configure WinRM. Open a command prompt. Become the administrator by doing

         runas /user:Administrator cmd

    and entering the password. Then run,

         winrm quickconfig -q
         winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
         winrm set winrm/config @{MaxTimeoutms="1800000"}
         winrm set winrm/config/service @{AllowUnencrypted="true"}
         winrm set winrm/config/service/auth @{Basic="true"}
         sc config WinRM start= auto

 12. Install [FreeSSHd](http://www.freesshd.com/). Create keys. Run it as a system service.

 13. Run the FreeSSHd link on the desktop. This will put a settings icon in the dock area at the bottom right.

 14. Add user `vagrant` with *Public key (SSH only)* authorization and allow *Shell*.

 15. Download the unsafe [public key](https://github.com/mitchellh/vagrant/blob/master/keys/vagrant.pub) and save it as `vagrant` (no file extension) in `C:\\Program Files\\freeSSHd`.

 16. Under `Allow program to communicate through Windows Firewall` allow freeSSHd through.

 17. Use explorer to navigate to the network. Turn on network discovery and file sharing (it'll ask).

 18. Restart such that the new freeSSHd settings take effect.

At this point the VM should be set up appropriately for it to work with vagrant and particularly `vagrant ssh`. To test it you can try creating a vagrant box,

    vagrant package --base "IE10 - Win7 Orig" --output ie10-win7.box
