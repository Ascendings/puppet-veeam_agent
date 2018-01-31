require File.expand_path(File.join(File.dirname(__FILE__), '..', 'veeam'))
Puppet::Type.type(:veeam_job).provide(:veeam, :parent => Puppet::Provider::Veeam) do
  desc "Veeam backup job management"

  def create
    # join the array of objects to backup into something usable
    objects = @resource[:objects].join(',')
    veeamconfig('job', 'create', '--name', "#{@resource[:name]}", '--repoName', "#{@resource[:repository]}", '--objects', "#{objects}")
  end

  def destroy
    veeamconfig('job', 'delete', '--name', "#{@resource[:name]}")
  end

  def exists?
    result = veeamconfig('job', 'list').lines
    if result.length > 1
      result.each_with_index do |line, index|
        # skip the first line of output, since it is just the table setup
        next if index == 0

        # split line into array by space
        bits = line.split(' ')
        # pull out the repository name
        job_name = bits[0]

        # return true here if the job exists
        return true if job_name == @resource[:name]
      end

      # return false if the job (by name) doesn't exist
      false
    else
      # return false if not job exists
      false
    end
  end

  # return the job's backup repository
  def repository
    result = veeamconfig('job', 'info', '--name', "#{@resource[:name]}").lines
    if result.length > 1
      result.each_with_index do |line, index|
        if line.strip.start_with?('Repository name:')
          bits = line.strip.split(': ')
          return bits[1].strip
        end
      end

      # the job's repository is not set if the job does not exist
      :absent
    else
      # the job's repository is not set if no job exists
      :absent
    end
  end

  # set the job's backup repository
  def repository=(value)
    # directory creation should be handled by the repository
    veeamconfig('job', 'edit', '--repoName', "#{value}", 'for', '--name', "#{@resource[:name]}")
  end

  # return the job's backup objects
  def objects
    # array to hold objects being backed up
    objects = []
    result = veeamconfig('job', 'info', '--name', "#{@resource[:name]}").lines

    # loop through every line of output
    result.each do |line|
      # the Include Disk lines are what we need
      if line.include? 'Include Disk:'
        # tease out the disk/volume being backed up
        object = line.split(': ')[1].strip
        # append the disk/volume to the array
        objects << object
      end
    end

    # return the disks/volumes being backed up, sorted properly
    return objects.sort_by(&:downcase)
  end

  # set the job's backup objects
  def objects=(value)
    # join the array of objects to backup into something usable
    objects = value.join(',')
    veeamconfig('job', 'edit', '--objects', "#{objects}", 'for', '--name', "#{@resource[:name]}")
  end
end
