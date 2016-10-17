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

    before(:all) do 
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

      it 'sets the matched_by field of OsMatch' do 
        OsMatch.last(2).each do |match|
          expect(match.matched_by).to eql User.last.id
          expect(match.user).to eql User.last
        end
      end

    end
    
    describe 'POST #unmatch_donation'do 
      before do 
        @os_match = double('os match')
        expect(@os_match).to receive(:destroy).exactly(3).times
        expect(OsMatch).to receive(:find).exactly(3).times.and_return(@os_match)
        post :unmatch_donation, {id: @entity.id, payload: [5,6,7]}
      end
      
      it 'has 200 status code' do 
        expect(response.status).to eq(200)
      end
    end

    describe 'GET /match_ny_donations' do
     it 'renders match_ny_donations page' do 
        get(:match_ny_donations, {id: @entity.id})
        expect(response.status).to eq(200)
        expect(response).to render_template(:match_ny_donations)
      end
    end  

  end
end

