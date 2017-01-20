## veeam_agent::package - installs the Package
class veeam_agent::package (
  # repo stuff
  $manage_repo = $::veeam_agent::manage_repo,
  $repo_name = $::veeam_agent::repo_name,
  $repo_ensure = $::veeam_agent::repo_ensure,

  # package stuff
  $package_name = $::veeam_agent::package_name,
  $package_ensure = $::veeam_agent::package_ensure,
){
  if $manage_repo {
    yumrepo { 'veeam_repo':
      name     => $repo_name,
      ensure   => $repo_ensure,
      descr    => 'Veeam Backup for GNU/Linux - $basearch',
      baseurl  => 'http://repository.veeam.com/backup/linux/agent/rpm/el/7/x86_64',
      enabled  => true,
      gpgcheck => true,
      gpgkey   => 'http://repository.veeam.com/keys/RPM-GPG-KEY-VeeamSoftwareRepo http://repository.veeam.com/keys/VeeamSoftwareRepos'
    }
  }

  # make sure epel and dkms are installed
  ensure_packages(['epel-release'])

  package { 'veeam_package':
    name    => $package_name,
    ensure  => $package_ensure,
    require => [ Yumrepo['veeam_repo'], Package['epel-release'], ],
  }
}
