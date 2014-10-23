define php2::version(
  $ensure  = 'installed',
  $env     = {},
  $version = $name,
) {
  require php2
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
}
