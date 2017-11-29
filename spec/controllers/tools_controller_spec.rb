require 'rails_helper'

describe ToolsController, type: :controller do
  it { should route(:get, '/tools/bulk/relationships').to(action: :bulk_relationships) }
  it { should route(:get, '/tools/merge').to(action: :merge_entities) }

  describe 'bulk_relationships' do
    login_user
    before do
      expect(Entity).to receive(:find).with('123').and_return(build(:person))
      get :bulk_relationships, entity_id: 123
    end
    it { should respond_with(200) }
    it { should render_template(:bulk_relationships) }
    it { should use_before_action(:authenticate_user!) }
    it { should use_before_action(:set_entity) }
  end

  describe 'merge_entities' do
    login_user
    before { get :merge_entities }
    it { should respond_with(200) }
    it { should render_template(:merge_entities) }
  end
end
