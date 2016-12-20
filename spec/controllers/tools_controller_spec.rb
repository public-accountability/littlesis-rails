require 'rails_helper'

RSpec.describe ToolsController, type: :controller do
  
  it { should route(:get, '/tools/bulk/relationships').to(action: :bulk_relationships) }

  describe 'bulk_relationships' do
    login_user
    before { get :bulk_relationships }
    it { should respond_with(200) }
    it { should render_template(:bulk_relationships) } 
  end
  
end
