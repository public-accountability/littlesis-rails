describe NewslettersConfirmationLink do
  it 'sets secret and created at' do
    link = NewslettersConfirmationLink.create('test@littlesis.org', ['tech'])
    expect(link.secret.length).to eq 32
    expect(link.created_at).to be_a ActiveSupport::TimeWithZone
  end

  it 'knows if expired' do
    link = NewslettersConfirmationLink.new('test@littlesis.org', ['tech'], SecureRandom.hex, 5.days.ago)
    expect(link).to be_expired
  end

  it 'finds valid link' do
    link = NewslettersConfirmationLink.create('test@littlesis.org', ['tech'])
    expect(link).to eq NewslettersConfirmationLink.find(link.secret)
  end

  it 'cannot find expired link' do
    link = NewslettersConfirmationLink.new('test@littlesis.org', ['tech'], SecureRandom.hex, 5.days.ago)
    Rails.cache.write(link.cache_key, link.to_a) # Write expired link to cache
    expect(NewslettersConfirmationLink.find(link.secret)).to be_nil
  end
end
