define php2::extension (
  $ensure  = 'present',
  $extension,
  $php,
  $provider = 'homebrew'
) {
  $php_version = regsubst($php, '\.', '')

  require php2::config
  require php2::fpm::config

  if ($provider == 'homebrew') {
    php_extension { $name:
      ensure         => $ensure,
      extension      => $extension,
      version        => $version,
      package_name   => $package_name,
      package_url    => "",
      homebrew_path  => $boxen::config::homebrewdir,
      phpenv_root    => $php2::config::root,
      php_version    => $php,
      cache_dir      => $php2::config::extensioncachedir,
    }
  }
  if ($provider == 'pecl') {
    package { $name:
      ensure => installed,
      package_settings => {
        php => $php,
        extension => $extension
      },
      provider => 'pecl'
    }
    file { "${boxen::config::homebrewdir}/etc/php/${php}/conf.d/ext-${extension}.ini":
      content => "zend_extension='${extension}.so'"
    }
    file_line { "Remove-${extension}-from-php.ini--${php}":
      ensure => absent,
      path   => "${boxen::config::homebrewdir}/etc/php/${php}/php.ini",
      line   => 'zend_extension="xdebug.so"',
    }
  }
}
