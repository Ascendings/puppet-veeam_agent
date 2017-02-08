Puppet::Type.newtype(:veeam_schedule) do
  ensurable

  # make sure the veeam package is installed first
  autorequire(:package) do
    'veeam_package'
  end

  autorequire(:veeam_job) do
    self[:job_name]
  end

  newparam(:name) do
    desc "The name of the Veeam backup schedule"
  end

  newparam(:job_name) do
    desc "The backup job to be scheduled"
    validate do |value|
      unless value =~ /[\w-]+/
        raise ArgumentError, "%s is not a valid backup job name" % value
      end
    end
  end

  newproperty(:weekdays, :array_matching => :all) do
    desc "Which days to run the Veeam backups"
    newvalues(:daily, :Monday, :Tuesday, :Wednesday, :Thursday, :Friday, :Saturday, :Sunday)
  end

  newproperty(:time) do
    desc "The objects for Veeam to backup"
    validate do |value|
      unless value =~ /([0-1][0-9]|[2][0-3]):[0-5][0-9]/
        raise ArgumentError, "The Veeam schedule's time must be in the format of HH:MM"
      end
    end
  end
end
