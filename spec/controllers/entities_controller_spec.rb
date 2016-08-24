require 'rails_helper'

describe EntitiesController, type: :controller do

  before(:each) do 
    DatabaseCleaner.start
  end

  after(:each) do 
    DatabaseCleaner.clean
  end

  describe 'GET' do 
    before do 
      @sf_user = create(:sf_guard_user)
      @user = create(:user, sf_guard_user_id: @sf_user.id)
      @entity = create(:mega_corp_inc, updated_at: Time.now, last_user: @sf_user)
    end
    
    describe "GET #show" do
      before do 
        
        get(:show, {id: @entity.id})
      end

      it 'renders show template' do
        expect(response).to render_template(:show) 
      end

      it 'sets the entity var' do 
        expect(assigns(:entity).id).to eql @entity.id
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
      @entity = create(:mega_corp_inc, last_user_id: SfGuardUser.last.id)
      get(:match_donations, {id: @entity.id})
    end

    it 'render match donations template' do 
      expect(response).to render_template(:match_donations)
    end
  end

  describe 'match/unmatch donations' do 
    login_user
    before do 
      @entity = create(:mega_corp_inc)
    end
    
    describe 'POST #match_donation' do
      before do
        d1 = create(:os_donation, fec_cycle_id: 'unique_id_1')
        d2 = create(:os_donation, fec_cycle_id: 'unique_id_2')
        post :match_donation, {id: @entity.id, payload: [d1.id, d2.id]}
      end
      
      it 'has 200 status code' do 
        expect(response.status).to eq(200)
      end

      it "updates the entity's last user id after matching" do 
        expect(@entity.reload.last_user_id).to eql SfGuardUser.last.id
      end

    end
    
    describe 'POST #unmatch_donation'do 
      before do 
        post :unmatch_donation, {id: @entity.id}
      end
      
      it 'has 200 status code' do 
        expect(response.status).to eq(200)
      end
    end

  end
end

