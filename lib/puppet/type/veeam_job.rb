Puppet::Type.newtype(:veeam_job) do
  ensurable

  autorequire(:veeam_repo) do
    self[:repository]
  end

  newparam(:name) do
    desc "The name of the Veeam backup job"
  end

  newproperty(:repository) do
    desc "The backup repository for this job"
    validate do |value|
      unless value =~ /[\w-]+/
        raise ArgumentError, "%s is not a valid backup repository name" % value
      end
    end
  end

  newproperty(:objects, :array_matching => :all) do
    desc "The objects for Veeam to backup"
    validate do |value|
      unless value.is_a? String
        raise ArgumentError, "objects requires an array of strings"
      end
    end
  end
end
