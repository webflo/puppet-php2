require 'puppet/util/execution'

Puppet::Type.type(:php_version).provide :php_homebrew do
  include Puppet::Util::Execution
  desc "Provides PHP versions compiled with homebrew-php"

  def self.home
    Facter.value(:homebrew_root)
  end

  def self.cache
    if boxen_home = Facter.value(:boxen_home)
      "#{boxen_home}/cache/homebrew"
    else
      ENV["HOMEBREW_CACHE"] || "/Library/Caches/Homebrew"
    end
  end

  def create
    unlink
    install "#{@resource[:name]}"
  end

  def exists?

  end

  def install(package)
    execute [ "brew", "boxen-install", package ], command_opts
  end

  def unlink
    options = command_opts.clone
    options[:failonfail] = false

    execute [ "brew", "unlink", "php@5.6" ], options
    execute [ "brew", "unlink", "php@7.0" ], options
    execute [ "brew", "unlink", "php@7.1" ], options
    execute [ "brew", "unlink", "php@7.2" ], options
    execute [ "brew", "unlink", "php" ], options
  end

  def homedir_prefix
    case Facter[:osfamily].value
    when "Darwin" then "Users"
    when "Linux" then "home"
    else
      raise "unsupported"
    end
  end

  def default_user
   Facter.value(:boxen_user) || Facter.value(:id) || "root"
  end

  def bottle_url
    Facter.value(:homebrew_bottle_url)
  end

  def command_opts
    @command_opts ||= {
      :combine            => true,
      :custom_environment => {
        "HOME"                      => "/#{homedir_prefix}/#{default_user}",
        "PATH"                      => "#{self.class.home}/bin:/usr/bin:/usr/sbin:/bin:/sbin",
        "BOXEN_HOMEBREW_BOTTLE_URL" => bottle_url,
        "HOMEBREW_CACHE"            => self.class.cache,
      },
      :failonfail         => true,
      :uid                => default_user
    }
  end

end
