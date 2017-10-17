require File.expand_path(File.join(File.dirname(__FILE__), '..', 'veeam'))
Puppet::Type.type(:veeam_vbrserver).provide(:veeam, :parent => Puppet::Provider::Veeam) do
  desc "Veeam Backup & Recovery server management"

  def create
    veeamconfig('vbrserver', 'add', '--name', @resource[:name],
        '--address', @resource[:server], '--port', @resource[:port],
        '--domain', "'#{@resource[:domain]}'", '--login', @resource[:username],
        '--password', @resource[:password])
  end

  def destroy
    veeamconfig('vbrserver', 'delete', '--name', @resource[:name])
  end

  def exists?
    begin
      result = veeamconfig('vbrserver', 'info', '--name', @resource[:name]).lines
      # we will also want to check if the job is enabled
      return (result.length > 1)
    rescue
      # veeamconfig will throw a hissy fit and force Puppet to fail if the
      #   server doesn't exist
      false
    end
  end

  def server
    result = veeamconfig('vbrserver', 'info', '--name', @resource[:name]).lines
    # tease out the endpoint server
    endpoint_addr = result[3].strip.split(': ')[1]
    return endpoint_addr.strip.split(':')[0]
  end

  def server=(value)
    veeamconfig('vbrserver', 'edit', '--name', @resource[:name], '--address', @resource[:server])
  end

  def port
    result = veeamconfig('vbrserver', 'info', '--name', @resource[:name]).lines
    # tease out the endpoint server
    endpoint_addr = result[3].strip.split(': ')[1]
    return endpoint_addr.strip.split(':')[1]
  end

  def port=(value)
    veeamconfig('vbrserver', 'edit', '--name', @resource[:name], '--port', @resource[:port])
  end
end
