require 'email_spec'
require 'email_spec/rspec'

describe ContactController, type: :controller do
  describe 'GET index' do
    before { get :index }

    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template('index') }
    it { is_expected.not_to set_flash.now }
  end

  describe 'POST create' do
    describe 'no name provided' do
      let(:params) { { contact_form: { email: 'email@email.com', message: 'hey' } } }

      before { post :create, params: params }

      it { is_expected.to set_flash.now[:errors] }
      it { is_expected.to render_template('index') }
    end

    describe 'no email provided' do
      let(:params) { { contact_form: { name: 'me', message: 'hey' } } }

      before { post :create, params: params }

      it { is_expected.to set_flash.now[:errors] }
      it { is_expected.to render_template('index') }
    end

    describe 'no message provided' do
      let(:params) { { contact_form: { email: 'email@email.com', message: '' } } }

      before { post :create, params: params }

      it { is_expected.to set_flash.now[:errors] }
      it { is_expected.to render_template('index') }
    end

    describe 'fields filled out' do
      let(:post_params) { { contact_form: { name: 'me', email: 'email@email.com', message: 'hey' } } }
      let(:form) { instance_double(ContactForm) }

      before do
        allow(ContactForm).to receive(:new).and_return(form)
        allow(form).to receive(:valid?).and_return(true)
        post :create, params: post_params
      end

      it { is_expected.not_to set_flash.now[:alert] }
      it { is_expected.to redirect_to(action: :index) }

      it 'sends the contact email', :run_jobs do
        email = open_last_email
        expect(email).to have_subject('Contact Us: ')
        expect(email.body).to have_text('hey')
      end
    end
  end
end
