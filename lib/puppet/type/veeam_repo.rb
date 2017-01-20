Puppet::Type.newtype(:veeam_repo) do
  ensurable

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
end
