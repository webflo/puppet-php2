define php2::symlinks (
  $ensure  = 'installed',
  $env     = {},
  $version = $name,
  $install_options = {}
) {
  require ::boxen::config
  require ::php2
  require ::php2::config

  # Config locations
  $version_config_root  = "${php2::config::configdir}/${version}"
  $php_ini              = "${version_config_root}/php.ini"
  $conf_d               = "${version_config_root}/conf.d"

  ensure_resource('php2::version', $version, {'ensure' => $ensure })

  file { "${conf_d}/z-10-default.ini":
    ensure => 'link',
    target => "${::php2::config::userconfigdir}/default.ini",
  }

  file { "${conf_d}/z-20-version.ini":
    ensure => 'link',
    target => "${::php2::config::userconfigdir}/${version}.ini",
  }

}
