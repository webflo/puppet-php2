define php2::fpm::apache($version) {
  ::apache_php::handler { "${name}":
    php_version => $version,
    idle_timeout => 3600,
  }
}
