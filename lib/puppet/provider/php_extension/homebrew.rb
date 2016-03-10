require 'puppet/util/execution'

Puppet::Type.type(:php_extension).provide(:homebrew) do
  include Puppet::Util::Execution
  desc "Provides PHP extensions compiled from a git repository"

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

  # Build and install our PHP extension
  def create
    unlink
    link
    install
  end

  def unlink
    options = command_opts.clone
    options[:failonfail] = false

    execute [ "brew", "unlink", "php53" ], options
    execute [ "brew", "unlink", "php54" ], options
    execute [ "brew", "unlink", "php55" ], options
    execute [ "brew", "unlink", "php56" ], options
    execute [ "brew", "unlink", "php70" ], options
  end

  def link
    version = @resource[:php_version].gsub '.', ''
    execute [ "brew", "link", "php#{version}" ], command_opts
  end

  def install
    package = @resource[:name]
    do_install = true

    begin
      execute [ "brew", "outdated", package], options
    rescue
      # Exit code 1, run upgade the package

      begin
        execute [ "brew", "upgrade", package ], command_opts
        do_install = false
      rescue
        # Update failed, trigger reinstall
        execute [ "brew", "remove", package ], command_opts
        do_install = true
      end
    end

    if do_install
      execute [ "brew", "install", package ], command_opts
    end
  end

  def destroy
    # FileUtils.rm_rf "#{@resource[:phpenv_root]}/versions/#{@resource[:php_version]}/modules/#{@resource[:extension]}.so"
  end

  def exists?
    # File.exists? "#{@resource[:phpenv_root]}/versions/#{@resource[:php_version]}/modules/#{@resource[:extension]}.so"
  end

protected

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
