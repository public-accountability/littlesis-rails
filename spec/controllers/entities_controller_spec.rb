require 'rails_helper'

describe EntitiesController, type: :controller do
  
  describe '/entities' do

    before do 
      create(:sf_user)
      user = create(:user)
      entity = create(:mega_corp_inc, last_user_id: user.id)
      get(:show, {id: entity.id})
    end
    
    describe "GET #show" do
      it 'renders show template' do
        expect(response).to render_template(:show) 
      end

      it 'finds last user who edited the entity' do 
        expect(assigns(:last_user).id).to eql(100)
      end
    end
  end
end

