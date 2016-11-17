class php2::composer {
  file { "${boxen::config::envdir}/composer.sh":
    source => 'puppet:///modules/php2/composer.sh';
  }
}
