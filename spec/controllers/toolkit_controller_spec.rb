require 'rails_helper'

describe ToolkitController, type: :controller do
  it { should route(:get, '/toolkit').to(action: :index) }

  describe '#index' do
    before do
      get :index
    end
    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should render_with_layout('toolkit') }
  end
end
