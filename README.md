# PHP Module for Boxen.

This module compiles multiple php version from homebrew/php.

## Usage

```puppet
php2::fpm { '5.4': }
php2::fpm { '5.5': }
php2::fpm { '5.6': }
```

## Required Puppet Modules

* `boxen`
* `homebrew`
