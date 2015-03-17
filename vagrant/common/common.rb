require 'yaml'

# Load the local overrides if there are any.
LOCAL_CONFIG_FILE = "#{ENV['HOME']}/.vagrant.neutrino.yaml"
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
    def vm_field name
      VMS_DICT.fetch("vms").fetch(@id).fetch(name)
    end
    
    # Returns a field from the common spec.
    def common_field name
      (VMS_DICT["common"] || {})[name]
    end

    # Returns a local override for the given name.
    def local_field name
      (LOCAL_DICT["common"] || {})[name]
    end

    # Returns the host port onto which the vm's ssh port should be mapped.
    def ssh_port
      self.vm_field "ssh_port"
    end

    # Returns the path where vagrant should look for local boxes.
    def local_box_path name
      boxes_root = (self.local_field "boxes_path") || ENV['VAGRANT_BOXES'] || "~/.boxes"
      "#{boxes_root}/#{name}"
    end 

    # Yields the list of externally configured synced folders.
    def synced_folders &thunk
      (self.common_field "synced_folders").each &thunk
      ((self.local_field "synced_folders") || []).each &thunk
    end

    # Sets all the configuration settings on a config that are controlled by
    # this set of external settings.
    def add_common_configs config
      # Mount the synced folders.
      self.synced_folders do | entry |
        config.vm.synced_folder entry["path"], entry["name"]
      end
      # Forward the ssh port. The id ensures that this is used instead of 2222
      # rather than in addition to.
      config.vm.network :forwarded_port, host: self.ssh_port, guest: 22, id: "ssh"
    end

  end

end

