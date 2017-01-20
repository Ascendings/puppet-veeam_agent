require File.expand_path(File.join(File.dirname(__FILE__), '..', 'veeam'))
Puppet::Type.type(:veeam_repo).provide(:veeam, :parent => Puppet::Provider::Veeam) do
  desc "Veeam backup repository management"

  def create
    veeamconfig('repository', 'create', '--name', "#{@resource[:name]}", '--location', "#{@resource[:location]}")
  end

  def destroy
    veeamconfig('repository', 'delete', '--name', "#{@resource[:name]}")
  end

  def exists?
    result = veeamconfig('repository', 'list').lines
    if result.length > 1
      result.each_with_index do |line, index|
        # skip the first line of output, since it is just the table setup
        next if index == 0

        # split line into array by space
        bits = line.split(' ')
        # pull out the repository name
        repo_name = bits[0]

        # we will want to return true if the repository does exist
        return true if repo_name == @resource[:name]
      end

      # return false if the repository (by name) does not exist
      false
    else
      # return false if not repository exists
      false
    end
  end

  # return the repository location
  def location
    result = veeamconfig('repository', 'list').lines
    if result.length > 1
      result.each_with_index do |line, index|
        # skip the first line of output, since it is just the table setup
        next if index == 0

        # split line into array by space
        bits = line.split(' ')
        # pull out the repository name
        repo_name = bits[0]

        return bits[2] if repo_name == @resource[:name]
      end

      # repository location isn't set if the repository doesn't exist
      :absent
    else
      # repository location isn't set if no repository exists
      :absent
    end
  end

  # set the repository location
  def location=(value)
    # veeamconfig will make the directory when a repository is created, but will
    #   not create it when simply changing a repository's location
    unless File.directory? value
      Dir.mkdir value
    end
    veeamconfig('repository', 'edit', '--location', "#{value}", 'for', '--name', "#{@resource[:name]}")
  end
end
