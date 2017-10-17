Puppet::Type.newtype(:veeam_vbrserver) do
  ensurable

  # make sure the veeam package is installed first
  autorequire(:package) do
    'veeam_package'
  end

  newparam(:name) do
    desc "The name of the Veeam Backup & Repository server"
  end

  newproperty(:server) do
    desc "The IP/Server name of the Veeam B&R server"
    validate do |value|
      unless value =~ /((([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))|(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9]))/
        raise ArgumentError, "The Veeam B&R server must be in the format of SERVER_NAME_OR_IP"
      end
    end
  end

  newproperty(:port) do
    desc "The port of the Veeam B&R server"
    validate do |value|
      unless value =~ /(6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]\d{4}|[1-9]\d{0,3})/
        raise ArgumentError, "The Veeam B&R port must be from 1 to 65535"
      end
    end
  end

  newparam(:domain) do
    desc "The login domain for the Veeam B&R server"
    validate do |value|
      unless value =~ /[\.\\]+|[\w\.]+/
        raise ArgumentError, "That is a not a valid Veeam B&R server login domain"
      end
    end
  end

  newparam(:username) do
    desc "The login username for the Veeam B&R server"
    validate do |value|
      unless value =~ /[\w-]+/
        raise ArgumentError, "That is not a valid Veeam B&R server login username"
      end
    end
  end

  newparam(:password) do
    desc "The login password for the Veeam B&R server"
  end
end
