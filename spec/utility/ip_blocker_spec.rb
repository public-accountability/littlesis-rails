describe IpBlocker do
  context 'when restricted_ips is blank' do
    before do
      Rails.application.config.littlesis.restricted_ips = nil
      Object.send :remove_const, :IpBlocker if Module.const_defined?(:IpBlocker)
      load 'ip_blocker'
    end

    it 'defines .restricted? and always returns false' do
      expect(IpBlocker.restricted?('10.10.10.10')).to eq false
    end
  end

  context 'when restricted_ips contains two ip ranges' do
    before do
      Rails.application.config.littlesis.restricted_ips = ['192.0.2.0/24', '192.0.3.0/24']
      Object.send :remove_const, :IpBlocker if Module.const_defined?(:IpBlocker)
      load 'ip_blocker'
    end

    it 'returns true if given ip is in restricted range' do
      expect(IpBlocker.restricted?('192.0.2.1')).to be true
    end

    it 'returns false for non-restricted ips' do
      expect(IpBlocker.restricted?('10.11.12.13')).to be false
    end
  end

  context 'when list of restricted ips contain invalid addresses' do
    before do
      Rails.application.config.littlesis.restricted_ips = ['192.0.2.0/24', 'FAKE']
      Object.send :remove_const, :IpBlocker if Module.const_defined?(:IpBlocker)
      load 'ip_blocker'
    end

    after do
      Rails.application.config.littlesis.restricted_ips = nil
    end

    it 'removes the invalid ip addresses from the list' do
      expect(IpBlocker::IPS.length).to eq 1
      expect(IpBlocker::IPS[0]).to eq IPAddr.new('192.0.2.0/24')
    end
  end
end
