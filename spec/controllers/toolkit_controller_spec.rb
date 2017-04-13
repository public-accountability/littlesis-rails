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

  describe '#markdown' do
    it 'can render markdown' do
      c = ToolkitController.new
      expect(c.send(:markdown, '# i am markdown'))
        .to eq "<h1>i am markdown</h1>\n"
    end
  end
end
