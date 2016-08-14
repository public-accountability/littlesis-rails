require 'rails_helper'

RSpec.describe OsCommittee, type: :model do
  # before(:all) do 
  #   @cmte = create(:os_committee)
  #   @mega_corp = create(:mega_corp_llc)
  #   @fundraising = create(:political_fundraising, 
  #                         entity_id: @mega_corp.id, 
  #                         os_committee_id: @cmte.id)
    
  # end
  
  # it 'has one PoliticalFundraising' do 
  #   expect(@cmte.political_fundraising).to eql @fundraising
  # end

  # it 'has one entity through PoliticalFundraising' do
  #   expect(@cmte.entity).to eql @mega_corp
  # end
  
  # it 'PoliticalFundraising belong to os_committee' do 
  #   expect(@fundraising.os_committees).to eql @cmte
  # end
end
