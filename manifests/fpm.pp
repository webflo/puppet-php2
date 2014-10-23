define php2::fpm (
  $ensure  = 'installed',
  $env     = {},
  $version = $name,
) {

  php2::version { $version:
    ensure => $ensure,
  }

  require php2::config
  require php2::fpm::config

  # Config file locations
  $version_config_root = "${php2::config::configdir}/${version}"
  $fpm_config          = "${version_config_root}/php-fpm.conf"
  $fpm_pool_config_dir = "${version_config_root}/pool.d"
  $pid_file            = "${php2::config::datadir}/${version}.pid"

  # Log files
  $error_log = "${php2::config::logdir}/${version}.fpm.error.log"

  # FPM Binary
  $bin = "${php2::config::root}/versions/${version}/sbin/php-fpm"

  # Set up FPM config
  file { $fpm_config:
    content => template('php2/php-fpm.conf.erb'),
    notify  => ::php2::fpm::service[$version],
  }

  # Set up FPM Pool config directory
  file { $fpm_pool_config_dir:
    ensure  => directory,
    recurse => true,
    force   => true,
    source  => 'puppet:///modules/php/empty-conf-dir',
    require => File[$version_config_root],
  }

  # Create a default pool, as FPM won't start without one
  # Listen on a fake socket for now
  $pool_name    = $version
  $socket_path  = "${boxen::config::socketdir}/${version}"
  $pm           = $php2::fpm::config::pm
  $max_children = $php2::fpm::config::pm_max_children
  $request_terminate_timeout = $php2::fpm::config::request_terminate_timeout

  # Additional non required options (as pm = static for this pool):
  $start_servers     = 1
  $min_spare_servers = 1
  $max_spare_servers = 1

  file { "${fpm_pool_config_dir}/${version}.conf":
    content => template('php2/php-fpm-pool.conf.erb'),
  }

  # Launch our FPM Service

  php2::fpm::service { $version:
    ensure    => running,
    subscribe => File["${fpm_pool_config_dir}/${version}.conf"],
  }
}
