# frozen_string_literal: true

# Checks if IP in listed in the configuration `restricted_ips`
# Used by confirmations to block ip rangers where spam bots sign up.
module IpBlocker
  if Rails.application.config.littlesis[:restricted_ips].blank?
    define_singleton_method(:restricted?) { |ip| false }
  else

    IPS = Rails.application.config.littlesis[:restricted_ips].map do |ip|
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
