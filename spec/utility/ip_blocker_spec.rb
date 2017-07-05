require 'rails_helper'

describe IpBlocker do

  def reload_mod
    # Removes the module from object-space:
    Object.send(:remove_const, :IpBlocker) if Module.const_defined?(:IpBlocker)
    # Reloads the module
    load Rails.root.join('app', 'utility', 'ip_blocker.rb')
  end
  
  context 'blacklist file is missing' do
    before do
      expect(File).to receive(:exist?)
                        .with(Rails.root.join('config', 'blacklist.yml')).and_return(false)
      reload_mod
    end

    it 'defines .blocked? and always returns false' do
      expect(IpBlocker.blocked?('10.10.10.10')).to eq false
    end
  end

  context 'blacklist file exists' do
    before do
      expect(File).to receive(:exist?)
                        .with(Rails.root.join('config', 'blacklist.yml')).and_return(true)

      expect(YAML).to receive(:load).and_return(['fake', '192.0.2.0/24'])

      reload_mod
    end
    
    it 'rejects invalid ip addresses from file' do
      expect(IpBlocker::IPS.length).to eq 1
      expect(IpBlocker::IPS[0]).to eq IPAddr.new('192.0.2.0/24')
    end

    it 'blocked? return true if ip address is in list' do
      
    end

    it 'blocked? return false if ip address is not inlist' do
      
    end
  end
      

  
end
