## veeam_agent::service - makes sure the veeam service is running
class veeam_agent::service (
  $service_name = $::veeam_agent::service_name,
  $service_ensure = $::veeam_agent::service_ensure,
){
  service { $service_name:
    ensure  => $service_ensure,
    require => Package['veeam_package'],
  }
}
