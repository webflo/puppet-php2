class php2::phpenv {
  require php2::config

  # Get rid of any pre-installed packages
  package { ['phpenv', 'php-build']: ensure => absent; }

  $phpenv_version = '6499bb6c7b645af3f4e67f7e17708d5ee208453f' # Pin to latest version of dev branch as of 2013-10-11

  file {
    [
      "${php2::config::root}/phpenv.d",
      "${php2::config::root}/phpenv.d/install",
      "${php2::config::root}/shims",
      "${php2::config::root}/versions",
      "${php2::config::root}/libexec",
    ]:
      ensure  => directory,
      require => Exec['phpenv-setup-root-repo'];
  }

  boxen::env_script {
    'phpenv':
      source => 'puppet:///modules/php2/phpenv.sh',
      priority => 'higher';
  }

  # Set up phpenv
  $git_init   = 'git init .'
  $git_remote = 'git remote add origin https://github.com/phpenv/phpenv.git'
  $git_fetch  = 'git fetch -q origin'
  $git_reset  = "git reset --hard ${phpenv_version}"

  exec { 'phpenv-setup-root-repo':
    command => "${git_init} && ${git_remote} && ${git_fetch} && ${git_reset}",
    cwd     => $php2::config::root,
    creates => "${php2::config::root}/bin/phpenv",
    require => [
      File[$php2::config::root],
      Class['git'],
    ]
  }

  exec { "ensure-phpenv-version-${phpenv_version}":
    command => "${git_fetch} && git reset --hard ${phpenv_version}",
    unless  => "git rev-parse HEAD | grep ${phpenv_version}",
    cwd     => $php2::config::root,
    require => Exec['phpenv-setup-root-repo']
  }
}
