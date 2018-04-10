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

    packages = pear('list', '-a').split("\n").map do |line|
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
      uid: default_user
    )
  end

  def latest
    target = @resource[:source] || @resource[:name]
    pear('remote-info', target).lines.find do |set|
      set =~ %r{^Latest}
    end.split[1]
  end

  def query
    self.class.pearlist(@resource)
  end

  def uninstall
    output = pear 'uninstall', @resource[:name]
    raise Puppet::Error, output unless output =~ %r{^uninstall ok}
  end

  def update
    install(false)
  end

  def default_user
    Facter.value(:boxen_user) || Facter.value(:id) || "root"
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
