require 'rails_helper'

describe OsMatch, type: :model do

  before(:all) do
    DatabaseCleaner.start
    Entity.skip_callback(:create, :after, :create_primary_ext)
    @loeb = create(:loeb)
    @nrsc = create(:nrsc)
    @loeb_donation = create(:loeb_donation) # relationship model
    @loeb_os_donation = create(:loeb_donation_one)
    @loeb_ref_one = create(:loeb_ref_one, object_id: @loeb_donation.id, object_model: "Relationship")
    @donation_class = create(:donation, relationship_id: @loeb_donation.id)
    @os_match = OsMatch.create(
      os_donation_id: @loeb_os_donation.id,
      donation_id: @donation_class.id,
      donor_id: @loeb.id,
      recip_id: @nrsc.id,
      reference_id: @loeb_ref_one.id,
      relationship_id: @loeb_donation.id)
  end

  after(:all) do
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end
  it 'belongs to os_donation' do 
    expect(@os_match.os_donation).to eql @loeb_os_donation
    expect(OsDonation.find(@loeb_os_donation.id).os_match).to eql @os_match
  end

  it 'belongs to donation' do
    expect(@os_match.donation).to eql @donation_class
    expect(Donation.find(@donation_class.id).os_matches).to eq [@os_match]
  end

  it 'belongs to donor via entity' do 
    expect(@os_match.donor).to eql @loeb
    expect(Entity.find(@loeb.id).contributions).to eq [@os_match]
  end
  
  it 'belongs to recipient via entity' do
    expect(@os_match.recipient).to eql @nrsc
    expect(Entity.find(@nrsc.id).donors).to eq [@os_match]
  end

  it 'belongs to a reference' do 
    expect(@os_match.reference).to eql @loeb_ref_one
    expect(Reference.find(@loeb_ref_one).os_match).to eql @os_match
    expect(Reference.find(@loeb_ref_one).os_donation).to eql @loeb_os_donation
  end

  it 'belongs to a relationship' do 
    expect(@os_match.relationship).to eql @loeb_donation
    expect(Relationship.find(@loeb_donation.id).os_matches).to eq [@os_match]
  end
  
  it 'requires os_donation_id' do 
    os_match = OsMatch.new(donor_id: 123)
    expect(os_match.valid?).to be false
    os_match.os_donation_id = 1
    expect(os_match.valid?).to be true
  end

  it 'requires donor_id' do
    os_match = OsMatch.new(os_donation_id: 10)
    expect(os_match.valid?).to be false
    os_match.donor_id = 1
    expect(os_match.valid?).to be true
  end

end
