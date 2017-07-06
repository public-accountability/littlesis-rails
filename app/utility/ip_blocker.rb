# Checks if ip in blacklist.yml
module IpBlocker
  if APP_CONFIG['restricted_ips'].blank?
    define_singleton_method(:restricted?) { |ip| false }
  else

    IPS = APP_CONFIG['restricted_ips'].map do |ip|
      begin
        IPAddr.new(ip)
      rescue IPAddr::InvalidAddressError
        nil
      end
    end.compact

    define_singleton_method(:restricted?) do |ip|
      IPS.each { |blocked_ip| return true if blocked_ip.include?(ip) }
      return false
    end
    
  end
end
