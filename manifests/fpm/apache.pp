define php2::fpm::apache($version) {
  file { "${::apache::config::configdir}/php/${version}.conf":
    ensure  => $ensure,
    content => template('php2/vhost_include.conf.erb'),
  }
}
