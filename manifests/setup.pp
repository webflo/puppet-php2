class php2::setup {
  include boxen::config
  include mysql::config

  file {
    [
      $php2::config::root,
      $php2::config::logdir,
      $php2::config::configdir,
      $php2::config::datadir,
      $php2::config::pluginsdir,
      $php2::config::cachedir,
      $php2::config::extensioncachedir,
    ]:
    ensure => directory
  }
}
