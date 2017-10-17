## veeam_agent - installs the veeam backup agent for Linux
class veeam_agent (
  # repo stuff
  $manage_repo = true,
  $repo_name = 'veeam',
  $repo_ensure = present,
  $ensure_epel = true,

  # package stuff
  $package_name = 'veeam',
  $package_ensure = present,

  # service stuff
  $service_name = 'veeamservice',
  $service_ensure = running,

  # Veeam stuff
  $veeam_repos = {},
  $veeam_jobs = {},
){
  # validate the parameters
  validate_bool($manage_repo)
  validate_string($service_name)

  # let's get stuff done
  include '::veeam_agent::package'
  include '::veeam_agent::service'

  Class['::veeam_agent::package'] -> Class['::veeam_agent::service']
}
