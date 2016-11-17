class php2::composer {
  boxen::env_script {
    "composer":
      source => "puppet:///modules/php2/composer.sh",
      priority => "lower"
  }
}
