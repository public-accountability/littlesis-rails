require 'rails_helper'

describe NysController, type: :controller do

  describe '#match_donations' do
    login_user
  
    it 'renders match_donations page for get' do 
      get(:match_donations)
      expect(response.status).to eq(200)
      expect(response).to render_template(:match_donations)
    end
    
  end

  describe '#potential_contributions' do
    login_user
    
    it 'returns 200' do 
      person = build(:person, id: 12345, name: "big donor")
      expect(Entity).to receive(:find).with(12345).and_return(person)
      expect(NyDisclosure).to receive(:search)
                               .with('big donor', :with=>{:is_matched=>false}  )
                               .and_return([{test: 'data'}])
      get(:potential_contributions, entity: '12345')
      expect(response.status).to eq(200)
    end
    
  end

end
