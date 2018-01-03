require 'rails_helper'

describe MergeController, type: :controller do
  describe "routes" do
    it { should route(:get, '/merge').to(action: :merge) }
    it { should route(:post, '/merge').to(action: :merge!) }
    it { should route(:get, '/merge/redundant').to(action: :redundant_merge_review) }
  end

  describe '#merge' do
    # TODO: consider deleting?
    let(:entity) { build(:org) }
    login_admin

    context 'search mode' do
      before do
        expect(Entity).to receive(:find).with(entity.id).and_return(entity)
        expect(entity).to receive(:similar_entities).with(75).and_return([])
        get :merge, params: { mode: 'search', source: entity.id }
      end

      it { should respond_with(200) }
      it { should render_template(:merge) }
      specify { expect(assigns(:merge_mode)).to eql 'search' }
    end

    context 'search mode with query' do
      before do
        expect(Entity).to receive(:find).with(entity.id).and_return(entity)
        expect(Entity::Search).to receive(:similar_entities)
                                    .with(entity, query: 'query', per_page: 75)
                                    .and_return([])
        get :merge, params: { mode: 'search', source: entity.id, query: 'query' }
      end

      it { should respond_with(200) }
      it { should render_template(:merge) }
      specify { expect(assigns(:merge_mode)).to eql 'search' }
      specify { expect(assigns(:query)).to eql 'query' }
    end

    context 'merge mode with query' do
      let(:source) { build(:org) }
      let(:dest) { build(:org) }

      before do
        expect(Entity).to receive(:find).with(source.id).and_return(source)
        expect(Entity).to receive(:find).with(dest.id).and_return(dest)
        get :merge, params: { mode: 'execute', source: source.id, dest: dest.id } 
      end

      it { should respond_with(200) }
      it { should render_template(:merge) }
      specify { expect(assigns(:merge_mode)).to eql 'execute' }
      specify { expect(assigns(:entity_merger)).to be_a EntityMerger }
    end
  end
end
