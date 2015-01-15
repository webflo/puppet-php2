define php2::version(
  $ensure  = 'installed',
  $env     = {},
  $version = $name,
) {
  require ::boxen::config
  require ::php2
  require ::php2::config

  $package = regsubst($name, '\.', '')

  package { "homebrew/php/php${package}":
    ensure => 'latest',
    install_options => [
      '--with-fpm',
      '--without-apache'
    ],
    before => exec["Unlink php${package}"],
    notify => exec["Unlink php${package}"]
  }

  exec { "Unlink php${package}":
    command     => "brew unlink php${package}",
  }

  file { "${php2::config::root}/versions/${name}":
   ensure => 'link',
   target => "/opt/boxen/homebrew/opt/php${package}",
  }


  # Install location
  $dest = "${php2::config::root}/versions/${version}"

  # Log locations
  $error_log = "${php2::config::logdir}/${version}.error.log"

  # Config locations
  $version_config_root  = "${php2::config::configdir}/${version}"
  $php_ini              = "${version_config_root}/php.ini"
  $conf_d               = "${version_config_root}/conf.d"

  # Module location for PHP extensions
  $module_dir = "${dest}/modules"

  # Data directory for this version
  $version_data_root = "${php2::config::datadir}/${version}"

  # Data directory
  file { $version_data_root:
    ensure => directory,
  }

  # Set up config directories
  file { $version_config_root:
    ensure => directory,
  }

  file { $conf_d:
    ensure  => directory,
    purge   => true,
    force   => true,
    require => File[$version_config_root],
  }

}
