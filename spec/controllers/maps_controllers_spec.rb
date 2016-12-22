require 'rails_helper'

describe MapsController, type: :controller do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  describe 'routes' do
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten').to(action: :show, id: '1706-colorado-s-terrible-ten') }
  end

  describe '#show' do
    def get_request
      expect(NetworkMap).to receive(:find).with("10-a-map").and_return(@map)
      get :show, {id: '10-a-map' }
    end

    it 'has two links if cloneable' do
      @map = build(:network_map, is_private: false, title: 'a map', is_cloneable: true)
      get_request
      expect(assigns(:links).length).to eql 2
    end

    it 'has one link if not cloneable' do
      @map = build(:network_map, is_private: false, title: 'a map', is_cloneable: false)
      get_request
      expect(assigns(:links).length).to eql 1
    end

    context 'GET with slug ' do
      before do
        @map = build(:network_map, is_private: false, title: 'a map')
        get_request
      end

      it { should respond_with :success }
      it { should render_template 'story_map' }

      it 'does not set dev_version' do
        expect(assigns(:dev_version)).to be_nil
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
      expect(NetworkMap).to receive(:find).with('10').and_return(@map)
      get :show, id: '10'
      expect(response.status).to eql 302
    end
  end

  describe '#dev' do
    login_user

    before do
      @map = build(:network_map, is_private: false, title: 'a map')
      expect(NetworkMap).to receive(:find).with('10-a-map').and_return(@map)
      expect(controller).to receive(:check_permission).with('admin')
      get :dev, id: '10-a-map'
    end

    it { should respond_with :success }
    it { should render_template 'story_map' }

    it 'sets dev_version' do
      expect(assigns(:dev_version)).to eql true
    end
  end
end
