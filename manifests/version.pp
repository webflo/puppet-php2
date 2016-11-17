define php2::version (
  $ensure  = 'installed',
  $env     = {},
  $version = $name,
  $install_options = {}
) {
  require ::boxen::config
  require ::php2
  require ::php2::config
  require ::php2::setup

  $package = regsubst($name, '\.', '')

  php_version { $package:
    provider          => "php_homebrew",
    user              => $::boxen_user,
    user_home         => "/Users/${::boxen_user}",
    phpenv_root       => $php2::config::root,
    version           => $package,
    homebrew_path     => $boxen::config::homebrewdir,
    install_options   => [
      '--with-fpm',
      '--without-apache'
    ]
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

  file { ["${boxen::config::homebrewdir}/etc/php/${version}", "${boxen::config::homebrewdir}/etc/php/${version}/conf.d"]:
    ensure => directory,
    recurse => true
  }

  file { $conf_d:
    ensure => 'link',
    target => "${boxen::config::homebrewdir}/etc/php/${version}/conf.d",
    force   => true,
    require => File[$version_config_root],
  }

  file { $php_ini:
    ensure => 'link',
    target => "${boxen::config::homebrewdir}/etc/php/${version}/php.ini",
    force   => true,
    require => File[$version_config_root],
  }

}
