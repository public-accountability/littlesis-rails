require 'rails_helper'

describe EntitiesController, type: :controller do

  
  describe 'GET' do 
    before do 
      @sf_user = create(:sf_user)
      @user = create(:user)
      @entity = create(:mega_corp_inc, last_user_id: @user.id)
    end
    
    describe "GET #show" do
      before do 
        
        get(:show, {id: @entity.id})
      end

      it 'renders show template' do
        expect(response).to render_template(:show) 
      end

      it 'finds last user who edited the entity' do 
        expect(assigns(:last_user).id).to eql(100)
      end
      
    end

    describe 'GET #relationships' do 
      before do 
        get(:relationships, {id: @entity.id})
      end

      it 'renders relationships template' do
        expect(response).to render_template(:relationships) 
      end

    end

    describe 'GET #political' do 

      before do 
        get(:political, {id: @entity.id})
      end

      it 'renders the politcal template' do
        expect(response).to render_template(:political) 
      end
    end

  end
  describe 'GET #match_donations' do
    login_user
    before do
      create(:sf_user)
      @entity = create(:mega_corp_inc, last_user_id: SfGuardUser.last.id)
      get(:match_donations, {id: @entity.id})
    end

    it 'render match donations template' do 
      expect(response).to render_template(:match_donations)
    end
  end

end

