require 'puppet/provider/package'

Puppet::Type.type(:package).provide :pear, parent: Puppet::Provider::Package do
  desc 'Package management via `pear`.'

  has_feature :versionable
  has_feature :upgradeable
  has_feature :install_options

  ENV['TERM'] = 'dumb' # remove colors

  commands pear: '/opt/boxen/phpenv/shims/pear'

  def self.pearlist(only = nil)
    channel = nil
    command_opts = {}

    if only
      command_opts = {
        :custom_environment => {
          "PHPENV_VERSION" => only[:package_settings]["php"]
        }
      }
    end

    result = execute([command(:pear), 'list', '-a'], command_opts)
    packages = result.split("\n").map do |line|
      # current channel
      %r{INSTALLED PACKAGES, CHANNEL (.*):}i.match(line) { |m| channel = m[1].downcase }

      # parse one package
      pearsplit(line, channel)
    end.compact

    return packages unless only

    packages.find do |pkg|
      pkg[:name].casecmp(only[:name].downcase).zero?
    end
  end

  def self.pearsplit(desc, channel)
    desc.strip!

    case desc
    when '' then nil
    when %r{^installed}i then nil
    when %r{no packages installed}i then nil
    when %r{^=} then nil
    when %r{^package}i then nil
    when %r{^(\S+)\s+(\S+)\s+(\S+)\s*$} then
      name = Regexp.last_match(1)
      version = Regexp.last_match(2)
      state = Regexp.last_match(3)

      {
        name: name,
        vendor: channel,
        ensure: state == 'stable' ? version : state,
        provider: self.name
      }
    else
      Puppet.warning format('Could not match %s', desc)
      nil
    end
  end

  def self.instances
    pearlist.map do |hash|
      new(hash)
    end
  end

  def install(useversion = true)
    command = ['-D', 'auto_discover=1', 'upgrade']

    if @resource[:install_options]
      command += join_options(@resource[:install_options])
    else
      command << '--alldeps'
    end

    pear_pkg = @resource[:source] || @resource[:name]
    if !@resource[:ensure].is_a?(Symbol) && useversion
      command << '-f'
      pear_pkg << "-#{@resource[:ensure]}"
    end
    command << pear_pkg

    Puppet::Util::Execution.execute(
      [command(:pear)] + command,
      uid: default_user,
      custom_environment: {
        "PHPENV_VERSION" => @resource[:package_settings]["php"]
      }
    )

  end

  def latest
    target = @resource[:source] || @resource[:name]
    result = execute([command(:pear), 'remote-info', target], command_opts)
    result.lines.find do |set|
      set =~ %r{^Latest}
    end.split[1]
  end

  def query
    self.class.pearlist(@resource)
  end

  def uninstall
    result = execute([command(:pear), 'uninstall', @resource[:name]], command_opts)
    raise Puppet::Error, result unless result =~ %r{^uninstall ok}
  end

  def update
    install(false)
  end

  def default_user
    Facter.value(:boxen_user) || Facter.value(:id) || "root"
   end

  def command_opts
    {
      :combine            => true,
      :custom_environment => {
        "PHPENV_VERSION" => @resource[:package_settings]["php"]
      },
      :failonfail         => true,
      :uid                => default_user
    }
  end

end
