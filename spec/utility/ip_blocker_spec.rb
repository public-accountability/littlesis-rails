require 'rails_helper'

describe IpBlocker do
  def reload_mod
    # Removes the module from object-space:
    Object.send(:remove_const, :IpBlocker) if Module.const_defined?(:IpBlocker)
    # Reloads the module
    load Rails.root.join('app', 'utility', 'ip_blocker.rb')
  end

  context 'restricted_ips is blank' do
    before do
      expect(APP_CONFIG).to receive(:[]).with('restricted_ips').and_return(nil)
      reload_mod
    end

    it 'defines .restricted? and always returns false' do
      expect(IpBlocker.restricted?('10.10.10.10')).to eq false
    end
  end

  context 'restricted_ips contains two ip ranges' do
    before do
      expect(APP_CONFIG).to receive(:[]).twice.with('restricted_ips')
                              .and_return(['192.0.2.0/24','192.0.3.0/24'])
      reload_mod
    end
    
    it 'returns true if given ip is in restricted range' do
      expect(IpBlocker.restricted?('192.0.2.1')).to be true
    end

    it 'returns fasle for non-restricted ips' do
      expect(IpBlocker.restricted?('10.11.12.13')).to be false
    end
  end

  context 'list of registristed ips contain invalid ip' do
    before do
      expect(APP_CONFIG).to receive(:[]).twice.with('restricted_ips')
                              .and_return(['192.0.2.0/24','FAKE'])
      reload_mod
    end

    it 'remove invalid ip addresses form list' do
      expect(IpBlocker::IPS.length).to eq 1
      expect(IpBlocker::IPS[0]).to eq IPAddr.new('192.0.2.0/24')
    end
  end
end
