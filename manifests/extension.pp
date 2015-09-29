define php2::extension (
  $ensure  = 'installed',
  $extension,
  $php
) {
  $php_version = regsubst($php, '\.', '')

  require php2::config
  require php2::fpm::config

  php_extension { $name:
    extension      => $extension,
    version        => $version,
    package_name   => $package_name,
    package_url    => "",
    homebrew_path  => $boxen::config::homebrewdir,
    phpenv_root    => $php2::config::root,
    php_version    => $php,
    cache_dir      => $php2::config::extensioncachedir,
  }

  # exec { "Link php${php_version} for ${name}":
  #   command => "/opt/boxen/repo/shared/php2/files/php-link php${php_version}",
  #   require => Php2::Fpm["${php}"]
  # } ->
  # package { "homebrew/php/${name}":
  #   ensure => 'latest'
  # }
}
