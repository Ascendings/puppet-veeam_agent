Puppet::Type.newtype(:veeam_repo) do
  ensurable

  # make sure the veeam package is installed first
  autorequire(:package) do
    'veeam_package'
  end

  autorequire(:veeam_vbrserver) do
    self[:server_name]
  end

  newparam(:name) do
    desc "The name of the Veeam repository"
  end

  newproperty(:location) do
    desc "The location of the Veeam backup repository"
    validate do |value|
      unless value =~ /(?:[\w-]+\/?)+/
        raise ArgumentError, "%s is not a valid backup repository location" % value
      end
    end
  end

  newparam(:server_name) do
    desc "The name of the Veeam B&R server - this should be the same name as the resource you define."
  end
end
