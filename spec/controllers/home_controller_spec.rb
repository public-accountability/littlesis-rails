require 'rails_helper'

describe HomeController, type: :controller do
  describe 'routes' do
    it { should route(:get, '/contact').to(action: :contact) }
    it { should route(:post, '/contact').to(action: :contact) }
    it { should route(:get, '/flag').to(action: :flag) }
    it { should route(:post, '/flag').to(action: :flag) }
  end

  describe 'GET #index' do
    before do
      expect_any_instance_of(HomeController).to receive(:redirect_to_dashboard_if_signed_in).and_return(nil)
      expect_any_instance_of(HomeController).to receive(:carousel_entities).and_return(double(:entities => double(:to_a => [])))
      get :index
    end

    it { should respond_with(200) }
    it { should render_template('index') }

    it 'has @dots_connected' do
      expect(assigns(:dots_connected)).to be_a(Array)
    end
  end

  describe 'GET contact' do
    before { get :contact }
    it { should respond_with(:success) }
    it { should render_template('contact') }
    it { should_not set_flash.now }
  end

  describe 'GET home/dashboard' do
    login_user

    before do
      network_maps = double('network_maps', order: [build(:network_map)])
      groups = double('groups', includes: double(order: []))
      edited_entities = double('edited', includes: double(order: double(limit: [])))
      expect(controller).to receive(:current_user).and_return(double(network_maps: network_maps), double(groups: groups), double(edited_entities: edited_entities))
      get :dashboard
    end

    it { should respond_with(:success) }
  end

  describe 'POST contact' do
    describe 'no name provided' do
      before { post :contact, email: 'email@email.com', message: 'hey' }
      it { should set_flash.now[:alert] }
      it { should render_template('contact') }
    end

    describe 'no email provided' do
      before { post :contact, { name: 'me', message: 'hey' } }
      it { should set_flash.now[:alert] }
      it { should render_template('contact') }
    end

    describe 'no message provided' do
      before { post :contact, name: 'me', email: 'email@email.com', message: '' }
      it { should set_flash.now[:alert] }
      it { should render_template('contact') }
      it ' assigns given name to @name' do
        expect(assigns(:name)).to eql 'me'
      end
    end

    describe 'fields filled out' do
      POST_PARAMS = { name: 'me', email: 'email@email.com', message: 'hey' }

      before do
        email = double('contact_email')
        expect(email).to receive(:deliver_later)
        expect(NotificationMailer).to receive(:contact_email).with(hash_including(POST_PARAMS)).and_return(email)
        post :contact, POST_PARAMS
      end

      it { should_not set_flash.now[:alert] }
      it { should set_flash.now[:notice] }
      it { should render_template('contact') }
    end
  end

  describe '/flag' do 
    describe 'GET' do
      before { get :flag }
      it { should respond_with(:success) }
      it { should render_template('flag') }
    end
  end
end
