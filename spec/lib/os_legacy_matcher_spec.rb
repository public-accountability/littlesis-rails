# The Os Legacy Matcher only needed to be run once.
# That has already happened.
# And, to make matters worse, these are buggy tests.

#require 'rails_helper'
# describe 'OsLegacyMatcher' do
#   before(:all) do
#     DatabaseCleaner.start
#     Entity.skip_callback(:create, :after, :create_primary_ext)
#     OsMatch.skip_callback(:create, :after, :post_process)
#     @loeb = create(:loeb)
#     @nrsc = create(:nrsc)
#     @nrsc_fundraising = create(:political_fundraising, entity_id: @nrsc.id)
#     @relationship = create(:loeb_donation, entity: @loeb, related: @nrsc)
#     @filing_one = create(:loeb_filing_one, relationship_id: @relationship.id)
#     @filing_two = create(:loeb_filing_two, relationship_id: @relationship.id)
#     @donation_one = create(:loeb_donation_one)
#     @donation_two = create(:loeb_donation_two)
#     @ref_one = create(:loeb_ref_one, object_id: @relationship.id)
#     @ref_two = create(:loeb_ref_two, object_id: @relationship.id)
#     @ref_three = create(:ref, name: "FEC Filing", source: "http://images.nictusa.com/cgi-bin/fecimg/?1234567", object_model: 'Relationship', object_id: @relationship.id)
#     # @suprepac = create(:os_committee)
#     @matcher = OsLegacyMatcher.new @relationship.id
#   end
  
#   after(:all) do
#     Entity.set_callback(:create, :after, :create_primary_ext)
#     OsMatch.set_callback(:create, :after, :post_process)
#     DatabaseCleaner.clean
#   end
  
#   describe '#initialize' do
#     it 'stores relationship id in instance var' do 
#       expect(@matcher.relationship_id).to eql @relationship.id
#     end
#   end

#   describe '#find_filings' do
#     it 'finds 2 filings' do 
#       @matcher.find_filings
#       expect(@matcher.filings.count).to eql(2)
#     end
#   end
  
#   describe '#find_references' do
#     it 'finds 3 references' do 
#       @matcher.find_references
#       expect(@matcher.references.count).to eql(3)
#     end
#   end

#   describe '#corresponding_os_donation' do
    
#     it 'finds the donation if the fec id & cycle matches' do 
#       filing = build(:loeb_filing_one, fec_filing_id: '1120620120011115314')
#       filing_found = @matcher.corresponding_os_donation(filing)
#       expect(filing_found).to eq(@donation_one)
#     end
    
#     it 'finds the donation if the fec_filing_id is the crp_id' do 
#       filing = build(:loeb_filing_one)
#       filing_found = @matcher.corresponding_os_donation(filing)
#       expect(filing_found).to eq(@donation_one)
#     end

#     it 'finds the donation if the fec_filing_id is the microfilm number' do 
#       filing = build(:loeb_filing_two)
#       filing_found = @matcher.corresponding_os_donation(filing)
#       expect(filing_found).to eq(@donation_two)
#     end
    
#   end

#   describe '#match_all' do 
    
#     it 'finds the fec_filing and calls match_one for each filing' do 
#       allow(FecFiling).to receive(:where) { [@donation_one, @donation_two] }
#       matcher = OsLegacyMatcher.new 555
#       expect(matcher).to receive(:match_one).twice
#       matcher.match_all
#     end
    
#   end


#   describe '#match_one' do 

#     it 'calls no_donation if no donation is found' do 
#       matcher = OsLegacyMatcher.new 555
#       expect(matcher).to receive(:no_donation).with(@filing_one)
#       expect(matcher).to receive(:corresponding_os_donation).and_return(nil)
#       matcher.match_one @filing_one
#     end

#     it 'calls create_os_match if a donation is returned' do
#       matcher = OsLegacyMatcher.new 555
#       expect(matcher).to receive(:corresponding_os_donation).and_return(@donation_one)
#       expect(matcher).to receive(:create_os_match).with(@donation_one, @filing_one)
#       matcher.match_one @filing_one
#     end
#   end

#   describe '#find_reference' do

#     # it 'raises ReferencesNotFoundError if no references are found' do
#     #   matcher = OsLegacyMatcher.new 555
#     #   filing = build(:loeb_filing_one, fec_filing_id: 'nope', crp_id: 'still_nope')
#     #   expect {matcher.find_reference filing, @donation_one} .to raise_error(OsLegacyMatcher::ReferencesNotFoundError)
#     # end

#     it 'finds ref when name includes fec filing id' do 
#       expect(@matcher.find_reference @filing_one, @donation_one).to eql @ref_one.id
#     end
    
#     it 'find ref when crp_id is in the filing name' do 
#       filing = build(:loeb_filing_two, fec_filing_id: '999999', crp_id: '10020853341')
#       expect(@matcher.find_reference filing, @donation_two).to eql @ref_two.id
#     end

#     it 'finds ref when link contains id' do 
#       filing = build(:loeb_filing_one, fec_filing_id: '1234567')
#       expect(@matcher.find_reference filing, @donation_one).to eql @ref_three.id
#     end

#     it 'creates a new donation if no reference is found' do 
#       ref_count = Reference.count
#       filing = build(:loeb_filing_one, fec_filing_id: '777777', crp_id: 'try to me me')
#       @matcher.find_reference filing, @donation_one
#       expect(Reference.count).to eql(ref_count + 1)
#     end
#   end

#   describe '#create_os_match' do

#     before(:all) do 
#       @matcher.create_os_match @donation_one, @filing_one
#       @os_match = OsMatch.last
#     end
    
#     it 'creates new os_match and is valid' do 
#       expect(@os_match).to be
#       expect(@os_match.valid?).to eql true
#     end

#     it 'has relationship association' do 
#       expect(@os_match.relationship).to eq @relationship
#     end
    
#     it 'has os_donation association' do 
#       expect(@os_match.os_donation).to eq @donation_one
#     end

#     it 'has donor association' do 
#       expect(@os_match.donor).to eq @loeb
#     end

#     it 'has recipient association' do 
#       expect(@os_match.recipient).to eq @nrsc
#     end

#     it 'has reference association' do 
#        expect(@os_match.reference).to eq @ref_one
#     end

#     it 'has donation assoication' do
#       expect(@os_match.donation).to be_a(Donation)
#       expect(@os_match.donation.relationship_id).to eq @relationship.id
#     end
    
#     it 'changes matched reference ref_type' do 
#       expect(Reference.find(@os_match.reference_id).ref_type).to eql(2)
#     end
    
#     it 'updates source link ' do 
#       expect(Reference.find(@os_match.reference_id).source).to eq @donation_one.reference_source
#     end

#     it 'sets cmte_id to be the same as recipient id' do
#       expect(@os_match.cmte_id).to eql @nrsc.id
#       expect(@os_match.recip_id).to eql@os_match.cmte_id
#     end
    
#   end

  
#   describe '#create_new_ref' do
    
#     before(:all) do
#       ref_id = @matcher.create_new_ref @donation_one
#       @new_ref = Reference.find(ref_id)
#     end

#     it 'creates new reference for the donation' do 
#       expect(@new_ref.name).to eql "FEC Filing 11020480483"
#       expect(@new_ref.source).to eql "http://docquery.fec.gov/cgi-bin/fecimg/?11020480483"
#       expect(@new_ref.publication_date).to eql "2011-11-29"
#       expect(@new_ref.object_id).to eql @relationship.id
#       expect(@new_ref.object_model).to eql "Relationship"
#       expect(@new_ref.ref_type).to eql 2
#     end
    
#   end


#   # This test requires the littlesis_raw database
#   # describe '#get_raw_info' do 
#   #   it 'retrieves correct row from raw database' do 
#   #     filing = build(:filing_raw_db_lookup)
#   #     expect(@matcher.get_raw_info filing).to include(
#   #                         :recipient_id => 'N00027829',
#   #                         :donor_name => 'DECONCINI, DENNIS',
#   #                         :zip => '92037')
#   #   end
#   # end

  
#   describe "#set_cmte_id" do
    
#     it 'sets cmte_id to be same as recipient if the recipient is an org' do 
#       os_match = OsMatch.new
#       os_match.recip_id = @nrsc.id
#       expect(os_match.cmte_id).to be_nil
#       @matcher.set_cmte_id OsDonation.new, os_match
#       expect(os_match.cmte_id).to eql(@nrsc.id)
#     end

#     it 'calls find_or_create_cmte if recipient is not an org' do 
#       os_match = OsMatch.new
#       os_match.recip_id = create(:elected).id
#       donation = OsDonation.new
#       matcher = OsLegacyMatcher.new 555
#       expect(matcher).to receive(:find_or_create_cmte).with(donation).once
#       matcher.set_cmte_id donation, os_match
#     end
#   end
  
#   describe "#find_or_create_cmte" do
#     it 'returns PoliticalFundraising id if found' do
#       corp = build(:mega_corp_inc)
#       PoliticalFundraising.create(fec_id: '6666', entity_id: corp.id)
#       donation = OsDonation.new { |d| d.cmteid = '6666' }
#       expect(@matcher.find_or_create_cmte donation).to eql(corp.id)
#     end

#     it 'calls create new committee if no entity is found' do 
#       matcher = OsLegacyMatcher.new 555
#       committee = OsCommittee.create(cmte_id: '1111', cycle: '2012')
     
#       donation = OsDonation.new { |d| 
#         d.cmteid = '1111' 
#         d.cycle = '2012' }
      
#       expect(matcher).to receive(:create_new_cmte).with(committee).once
#       matcher.find_or_create_cmte donation
      
#     end
#   end

#   describe '#create_new_cmte' do 
#     before do 
#       Entity.set_callback(:create, :after, :create_primary_ext)
#       @cmte = create(:os_committee)
#       @id = @matcher.create_new_cmte @cmte
#       @e = Entity.last
#     end

#     after do 
#       Entity.skip_callback(:create, :after, :create_primary_ext)
#     end
    
#     it 'creates a new entity' do 
#       expect(@e.name).to eql "SuprePac"
#     end

#     it 'creates ExtensionRecord' do
#       expect(@e.extension_records.count).to eql(2)
#       expect(@e.extension_records.last.definition_id).to eql(11)
#     end

#     it 'creates PoliticalFundraising' do
#       expect(PoliticalFundraising.where(entity_id: @e.id).count).to eql(1)
#       expect(@e.political_fundraising.fec_id).to eql 'C00000042'
#     end

#     it 'returns the entity id' do 
#       expect(@id).to eql @e.id
#     end

#   end

#   describe "#add_os_cmte_ref_to_fundraising" do
#   end


#   describe '#ref_link_helper' do 
    
#     it 'extracts fec image number' do
#       ref = build(:ref, source: "http://images.nictusa.com/cgi-bin/fecimg/?28931320327", object_id: 123)
#       expect(@matcher.ref_link_helper ref). to eql "28931320327"
#     end
    
    
#   end

# end
