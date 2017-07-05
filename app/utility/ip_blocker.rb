# Checks if ip in blacklist.yml
module IpBlocker
  if File.exist?(Rails.root.join('config', 'blacklist.yml'))

    IPS = YAML.load(File.new(Rails.root.join('config', 'blacklist.yml')).read).map do |ip|
      begin
        IPAddr.new(ip)
      rescue IPAddr::InvalidAddressError
        nil
      end
    end.compact

    define_singleton_method('blocked?') do |ip|
      
    end

  else
    define_singleton_method('blocked?') { |ip| false }
  end
end
