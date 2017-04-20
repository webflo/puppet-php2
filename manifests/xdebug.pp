class php2::xdebug {
  require php2::config

  file { "${php2::config::root}/bin/xdebug":
    source => "puppet:///modules/php2/xdebug",
    mode => "0755"
  }

  boxen::env_script {
    "xdebug":
      source => "puppet:///modules/php2/xdebug.sh",
      priority => "lower"
  }
}
