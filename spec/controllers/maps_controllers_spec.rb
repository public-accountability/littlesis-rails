require 'rails_helper'

describe MapsController, type: :controller do
  before(:all)  { DatabaseCleaner.start  }
  after(:all)  { DatabaseCleaner.clean  }

  describe '#show' do

    def get_request
      expect(NetworkMap).to receive(:find).with("10-a-map").and_return(@map)
      get :show, {id: "10-a-map"}
    end

    context 'GET with slug ' do 
      before do
        @map = build(:network_map, is_private: false, title: 'a map')
        get_request
      end
      
      it { should respond_with :success }
      it { should render_template 'story_map' }
      
      it 'does not set dev_version' do 
        expect(assigns :dev_version).to be_nil
      end
    end
    
    context 'private map - anon user' do 
      before do 
        @map = build(:network_map, is_private: true, title: 'a map')
        get_request
      end
      it { should respond_with 403 }
    end

    it 'redirects if no slug is provided' do 
      @map = build(:network_map, is_private: false, title: 'a map')
      expect(NetworkMap).to receive(:find).with("10").and_return(@map)
      get :show, {id: "10"}
      expect(response.status).to eql 302 
    end
  end

  describe '#dev' do 
    login_user

    before do 
      @map = build(:network_map, is_private: false, title: 'a map')
      expect(NetworkMap).to receive(:find).with("10-a-map").and_return(@map)
      expect(controller).to receive(:check_permission).with('admin')
      get :dev, {id: "10-a-map"}
    end
    
    it { should respond_with :success }
    it { should render_template 'story_map' }
    
    it 'sets dev_version' do 
      expect(assigns :dev_version).to eql true
    end
  end
   
end
