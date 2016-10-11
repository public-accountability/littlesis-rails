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
end
