require 'yaml'

# Load the local overrides if there are any.
LOCAL_CONFIG_FILE = "#{ENV['HOME']}/.config/tundra/vagrant.yaml"
if File.exist?(LOCAL_CONFIG_FILE)
  LOCAL_DICT = YAML::load(File.open(LOCAL_CONFIG_FILE))
else
  LOCAL_DICT = {}
end

# Load the common configuration file.
VMS_DICT = YAML::load(File.open("../../vms.yaml"))

module Common

  # Wrapper around the external properties for a particular vm.
  class Externs
    def initialize id
      @id = id
    end

    # Returns a field from the vm spec associated with this vm.
    def shared_vm_field(name, default=nil)
      VMS_DICT.fetch("vms").fetch(@id).fetch(name, default)
    end

    # Returns a field from the local vm overrides.
    def local_vm_field(name, default=nil)
      LOCAL_DICT.fetch("vms", {}).fetch(@id, {}).fetch(name, default)
    end

    # Returns the value of the vm field with the given name, taking local vm
    # overrides into account.
    def vm_field(name, default=nil)
      self.local_vm_field(name, self.shared_vm_field(name, default))
    end

    # Returns a field from the common spec.
    def shared_common_field(name, default=nil)
      VMS_DICT.fetch("common", {}).fetch(name, default)
    end

    # Returns a local common override for the given name.
    def local_common_field(name, default=nil)
      LOCAL_DICT.fetch("common", {}).fetch(name, default)
    end

    # Returns the value of the common field with the given name, taking local
    # overrides into account.
    def common_field(name, default=nil)
      self.local_common_field(name, self.shared_common_field(name, default))
    end

    def shared_os_field(name, default=nil)
      VMS_DICT.fetch(self.os, {}).fetch(name, default)
    end

    def local_os_field(name, default=nil)
      LOCAL_DICT.fetch(self.os, {}).fetch(name, default)
    end

    def os_field(name, default=nil)
      self.local_os_field(name, self.shared_os_field(name, default))
    end

    # Returns the host port onto which the vm's ssh port should be mapped.
    def ssh_port
      self.nearest_field "ssh_port"
    end

    def os
      self.vm_field "os"
    end

    def gui
      self.nearest_field("gui", false)
    end

    # Returns the path where vagrant should look for local boxes.
    def local_box_path name
      boxes_root = (self.nearest_field "boxes_path") || ENV['VAGRANT_BOXES'] || "~/.boxes"
      "#{boxes_root}/#{name}"
    end

    # Invokes the given block for each entry of the field with the given name
    # in the union of common, local, and vm-specific configs.
    def each_field(name, &thunk)
      self.local_common_field(name, []).each &thunk
      self.shared_common_field(name, []).each &thunk
      self.local_os_field(name, []).each &thunk
      self.shared_os_field(name, []).each &thunk
      self.local_vm_field(name, []).each &thunk
      self.shared_vm_field(name, []).each &thunk
    end

    # Yields the field with the given name from the nearest config in the order
    # local overrides < vm settings < common defaults < explicit default.
    def nearest_field(name, default=nil)
      self.vm_field(name, self.os_field(name, self.common_field(name, default)))
    end

    # Yields the path to the private key to use.
    def private_key_path
      self.nearest_field "private_key_path"
    end

    # Yields the list of externally configured synced folders.
    def synced_folders &thunk
      self.each_field("synced_folders", &thunk)
    end

    def forwarded_ports &thunk
      self.each_field("forwarded_ports", &thunk)
    end

    # Sets all the configuration settings on a config that are controlled by
    # this set of external settings.
    def add_common_configs config
      config.ssh.private_key_path = self.private_key_path
      # Mount the synced folders.
      self.synced_folders do |entry|
        config.vm.synced_folder entry["path"], entry["name"]
      end
      self.forwarded_ports do |entry|
        config.vm.network :forwarded_port,
          host: entry["host"],
          guest: entry["guest"],
          id: entry["id"]
      end
      # Forward the ssh port. The id ensures that this is used instead of 2222
      # rather than in addition to.
      config.vm.network :forwarded_port,
        host: self.ssh_port,
        guest: 22,
        id: "ssh"
      config.vm.provider :virtualbox do |vb|
        vb.gui = self.gui
      end
    end

  end

  # Apply the default configuration based on the given id. If a thunk is passed
  # it will be called with the vagrant config and the externs object which can
  # be used to override the default settings.
  def self.configure(id, &thunk)
    externs = Externs.new id
    default_box = externs.local_box_path ("%s.box" % id)
    Vagrant.configure("2") do |config|
      config.vm.box = id
      config.vm.box_url = default_box

      externs.add_common_configs config

      thunk.call(config, externs) unless thunk.nil?
    end
  end

  # Works the same way as .configure but sets up additional options for running
  # a windows box.
  def self.configure_windows(id, &thunk)
    self.configure(id) do |config, externs|
      config.vm.communicator = :winrm

      thunk.call(config, externs) unless thunk.nil?
    end
  end

end
