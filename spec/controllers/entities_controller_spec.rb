require 'rails_helper'

describe EntitiesController, type: :controller do
  
  describe '/entities' do

    before do 
      cookies.clear
      create(:sf_user)
      user = create(:user)
      entity = create(:mega_corp_inc, last_user_id: user.id)
      get(:show, {id: entity.id})
    end
    
    describe "GET #show" do
      it 'renders show template' do
        expect(response).to render_template(:show) 
      end
    end
  end
end

