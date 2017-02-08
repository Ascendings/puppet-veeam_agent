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
  case $::architecture {
    'i386', 'x86': {
      $arch = 'i386'
    },
    'amd64', 'x86_64': {
      $arch = 'x86_64'
    },
    default: {
      fail("The Veeam repositories do not support the ${::architecture} architecture")
    }
  }

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
      file { 'veeam_gpg_key':
        ensure => present,
        path   => '/etc/apt/trusted.gpg.d/veeam.gpg',
        source => 'puppet:///modules/veeam_agent/files/trusted.gpg.d/veeam.gpg',
      }

      apt::repo { 'veeam':
        comment  => 'Debian repository for Veeam Endpoint Backup Agent for Linux',
        location => "http://repository.veeam.com/backup/linux/agent/dpkg/debian/${arch}/",
        release  => 'noname',
        repos    => 'veeam',
        include  => {
          'deb' => true,
        },
        require  => File['veeam_gpg_key'],
      }

      package { 'veeam_package':
        ensure  => $package_ensure,
        name    => $package_name,
        require => Apt::Repo['veeam'],
      }
    }

    default: {
      fail("${::operatingsystem} is not supported yet!")
    }
  }
}
