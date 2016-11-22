require 'rails_helper'

describe HomeController, type: :controller do 

  describe 'GET #index' do 
    
    before do 
      expect(List).to receive(:find).with(404).and_return(double(:entities => double(:to_a => [])))
      expect_any_instance_of(HomeController).to receive(:redirect_to_dashboard_if_signed_in).and_return(nil)
      get :index
    end
    
    it 'responds with 200' do
      expect(response.status).to eq(200)
    end

    it { should render_template('index') }

    it 'has @dots_connected' do 
      expect(assigns(:dots_connected)).to be_a(Array)
    end
    
  end

  describe 'GET contact' do
    
    before { get :contact } 
    
    it 'is successful' do 
      expect(response).to be_success
    end 

    it { should render_template('contact') }
    it { should_not set_flash.now }

  end

  describe 'POST contact'do 

    describe 'no name provided' do 
      before { post :contact, {email: 'email@email.com', message: 'hey'} }
      it { should set_flash.now[:alert] }
      it { should render_template('contact') }
    end

    describe 'no email provided' do 
      before { post :contact, {name: 'me', message: 'hey'} }
      it { should set_flash.now[:alert] }
      it { should render_template('contact') }
    end

    describe 'no message provided' do 
      before { post :contact, {name: 'me', email: 'email@email.com', message: ''} }
      it { should set_flash.now[:alert] }
      it { should render_template('contact') }
      it ' assigns given name to @name' do 
        expect(assigns(:name)).to eql 'me'
      end
    end

    describe 'fields filled out' do 
      POST_PARAMS = {name: 'me', email: 'email@email.com', message: 'hey'}
      
      before do 
        email = double("contact_email")
        expect(email).to receive(:deliver_later)
        expect(NotificationMailer).to receive(:contact_email).with(hash_including(POST_PARAMS)).and_return(email)
        post :contact, POST_PARAMS
      end

      it { should_not set_flash.now[:alert] }
      it { should set_flash.now[:notice] }
      it { should render_template('contact') }
      
    end

  end
end
