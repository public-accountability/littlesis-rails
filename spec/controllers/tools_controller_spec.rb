require 'rails_helper'

describe ToolsController, type: :controller do
  it { should route(:get, '/tools/bulk/relationships').to(action: :bulk_relationships) }
  it { should route(:get, '/tools/merge').to(action: :merge_entities) }
  it { should route(:post, '/tools/merge').to(action: :merge_entities!) }

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
    #TODO consider deleting?
    let(:entity) { build(:org) }
    login_admin

    context 'search mode' do
      before do
        expect(Entity).to receive(:find).with(entity.id).and_return(entity)
        expect(entity).to receive(:similar_entities).with(75).and_return([])
        get :merge_entities, mode: 'search', source: entity.id
      end

      it { should respond_with(200) }
      it { should render_template(:merge_entities) }
      specify { expect(assigns(:merge_mode)).to eql 'search' }
    end

    context 'search mode with query' do
      before do
        expect(Entity).to receive(:find).with(entity.id).and_return(entity)
        expect(Entity::Search).to receive(:similar_entities)
                                    .with(entity, query: 'query', per_page: 75)
                                    .and_return([])
        get :merge_entities, mode: 'search', source: entity.id, query: 'query'
      end

      it { should respond_with(200) }
      it { should render_template(:merge_entities) }
      specify { expect(assigns(:merge_mode)).to eql 'search' }
      specify { expect(assigns(:query)).to eql 'query' }
    end

    context 'merge mode with query' do
      let(:source) { build(:org) }
      let(:dest) { build(:org) }

      before do
        expect(Entity).to receive(:find).with(source.id).and_return(source)
        expect(Entity).to receive(:find).with(dest.id).and_return(dest)
        get :merge_entities, mode: 'execute', source: source.id, dest: dest.id
      end

      it { should respond_with(200) }
      it { should render_template(:merge_entities) }
      specify { expect(assigns(:merge_mode)).to eql 'execute' }
      specify { expect(assigns(:entity_merger)).to be_a EntityMerger }
    end
  end
end
