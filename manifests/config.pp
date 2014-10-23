# Base configuration values for PHP
#
# Usage:
#
#     include php2::config
#
class php2::config {
  require boxen::config

  $root              = "${boxen::config::home}/phpenv"
  $logdir            = "${boxen::config::logdir}/php"
  $configdir         = "${boxen::config::configdir}/php"
  $datadir           = "${boxen::config::datadir}/php"
  $pluginsdir        = "${root}/plugins"
  $cachedir          = "${php2::config::datadir}/cache"
  $extensioncachedir = "${php2::config::datadir}/cache/extensions"
  $configprefix      = "10-"
}
