require 'rails_helper'

describe Api::ApiController, type: :controller do
  describe 'index' do
    before { get :index }
    it { should respond_with(:success) }
    it { should render_template('api/index') }
    it { should render_with_layout('application') }
  end

  describe 'param_to_bool' do
    let(:api_controller) { Api::ApiController.new }

    it 'converts vals to true' do
      expect(api_controller.param_to_bool('true')).to be true
      expect(api_controller.param_to_bool('TRUE')).to be true
      expect(api_controller.param_to_bool('1')).to be true
    end

    it 'converts vals to false' do
      expect(api_controller.param_to_bool('false')).to be false
      expect(api_controller.param_to_bool('FALSE')).to be false
      expect(api_controller.param_to_bool('0')).to be false
      expect(api_controller.param_to_bool(nil)).to be false
    end
  end
end
