require 'rails_helper'

describe Api::ApiController, type: :controller do
  describe 'index' do
    before { get :index }
    it { should respond_with(:success) }
    it { should render_template('api/index') }
    it { should render_with_layout('application') }
  end
end
