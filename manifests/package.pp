## veeam_agent::package - installs the Package
class veeam_agent::package (
  # repo stuff
  $manage_repo = $::veeam_agent::manage_repo,
  $repo_name = $::veeam_agent::repo_name,
  $repo_ensure = $::veeam_agent::repo_ensure,
  $ensure_epel = true,

  # package stuff
  $package_name = $::veeam_agent::package_name,
  $package_ensure = $::veeam_agent::package_ensure,
){
  case $::osfamily {
    'redhat': {
      case $::operatingsystem {
        'redhat', 'centos': {
          if $manage_repo {
            yumrepo { 'veeam_repo':
              ensure   => $repo_ensure,
              name     => $repo_name,
              descr    => 'Veeam Backup for GNU/Linux - $basearch',
              baseurl  => "http://repository.veeam.com/backup/linux/agent/rpm/el/${::operatingsystemmajrelease}/\$basearch",
              enabled  => true,
              gpgcheck => true,
              gpgkey   => 'http://repository.veeam.com/keys/RPM-GPG-KEY-VeeamSoftwareRepo http://repository.veeam.com/keys/VeeamSoftwareRepos'
            }
          }
        }
        'fedora': {
          if $manage_repo {
            yumrepo { 'veeam_repo':
              ensure   => $repo_ensure,
              name     => $repo_name,
              descr    => 'Veeam Backup for GNU/Linux - $basearch',
              baseurl  => "http://repository.veeam.com/backup/linux/agent/rpm/fc/${::operatingsystemmajrelease}/\$basearch",
              enabled  => true,
              gpgcheck => true,
              gpgkey   => 'http://repository.veeam.com/keys/RPM-GPG-KEY-VeeamSoftwareRepo http://repository.veeam.com/keys/VeeamSoftwareRepos'
            }
          }
        }
        default: {
          fail("${::operatingsystem} is not supported yet!")
        }
      }

      if $ensure_epel {
        # make sure epel is installed
        ensure_packages(['epel-release'])
      }

      package { 'veeam_package':
        ensure  => $package_ensure,
        name    => $package_name,
        require => [ Yumrepo['veeam_repo'], Package['epel-release'], ],
      }
    }

    'debian': {
      fail("${::osfamily} family OSes will be supported in a future release")
    }

    default: {
      fail("${::operatingsystem} is not supported yet!")
    }
  }
}
