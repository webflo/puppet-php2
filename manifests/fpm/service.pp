# Manages a PHP FPM service
#
# Usage:
#
#     php2::fpm::service { '5.4':
#       ensure => running
#     }
#
define php2::fpm::service(
  $version = $name,
  $ensure  = running,
) {
  require php2::config

  # Config file locations
  $fpm_config = "${php2::config::configdir}/${version}/php-fpm.conf"

  # Log files
  $logfile = "${php2::config::logdir}/${version}.error.log"

  # FPM Binary
  $bin = "${php2::config::root}/versions/${version}/sbin/php-fpm"

  # Working Directory?
  $cwd = "${php2::config::root}/versions/${version}"

  if $ensure == running {

    # Register and fire up our FPM instance

    file { "/Library/LaunchDaemons/dev.php2-fpm.${version}.plist":
      content => template('php2/dev.php2-fpm.plist.erb'),
      group   => 'wheel',
      owner   => 'root',
    }

    service { "dev.php2-fpm.${version}":
      ensure    => running,
      subscribe => File["/Library/LaunchDaemons/dev.php2-fpm.${version}.plist"],
    }

  } else {

    file { "/Library/LaunchDaemons/dev.php2-fpm.${version}.plist":
      ensure  => absent,
      require => Service["dev.php2-fpm.${version}"],
    }

    service { "dev.php2-fpm.${version}":
      ensure  => stopped,
    }
  }
}
