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

}
