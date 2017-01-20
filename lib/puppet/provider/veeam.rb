class Puppet::Provider::Veeam < Puppet::Provider

  initvars

  # make sure that /bin is in the path
  ENV['PATH']=ENV['PATH'] + ':/bin'

  # easy reference to the veeamconfig command
  commands :veeamconfig => 'veeamconfig'

end
