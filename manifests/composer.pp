class php2::composer() {
  require php2::config
  $composer_path = "${php2::config::root}/bin/composer"

  exec { 'download-php-composer':
    command => "php /opt/boxen/repo/shared/php2/files/tiny-composer-installer.php ${$composer_path}",
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
