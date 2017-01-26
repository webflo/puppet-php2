class php2::composer {
  require php2::config

  $composer_version = hiera("php2::composer::version")
  $composer_checksum = hiera("php2::composer::checksum")
  $composer_url = "https://getcomposer.org/download/${composer_version}/composer.phar"
  $composer_path = "${php2::config::root}/bin/composer"

  exec { 'download-php-composer':
    command => "curl -sS -o ${composer_path} ${composer_url}",
    unless  => "[ -f ${composer_path} ] && [ \"`shasum -a 384 -q ${composer_path}`\" = \"${composer_checksum}\" ]",
    cwd     => $php2::config::root,
    require => Exec['phpenv-setup-root-repo']
  } ->

  file { $composer_path:
    mode => '0755'
  }

  boxen::env_script {
    "composer":
      source => "puppet:///modules/php2/composer.sh",
      priority => "lower"
  }
}
