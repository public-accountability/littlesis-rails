describe MergeController, type: :controller do
  describe "routes" do
    it { is_expected.to route(:get, '/merge').to(action: :merge) }
    it { is_expected.to route(:post, '/merge').to(action: :merge!) }
    it { is_expected.to route(:get, '/merge/redundant').to(action: :redundant_merge_review) }
  end

  describe '#merge' do
    # TODO: consider deleting?
    let(:entity) { build(:org) }

    login_admin

    describe 'search mode' do
      before do
        expect(Entity).to receive(:find).with(entity.id).and_return(entity)
        expect(entity).to receive(:similar_entities).with(75).and_return([])
        get :merge, params: { mode: 'search', source: entity.id }
      end

      it { is_expected.to respond_with(200) }
      it { is_expected.to render_template(:merge) }
      specify { expect(assigns(:merge_mode)).to eql 'search' }
    end

    describe 'search mode with query' do
      before do
        expect(Entity).to receive(:find).with(entity.id).and_return(entity)
        expect(SimilarEntitiesService).to receive(:new)
                                            .with(entity, query: 'query', per_page: 75)
                                            .and_return(double(:similar_entities => []))
        get :merge, params: { mode: 'search', source: entity.id, query: 'query' }
      end

      it { is_expected.to respond_with(200) }
      it { is_expected.to render_template(:merge) }
      specify { expect(assigns(:merge_mode)).to eql 'search' }
      specify { expect(assigns(:query)).to eql 'query' }
    end

    describe 'merge mode with query' do
      let(:source) { build(:org) }
      let(:dest) { build(:org) }

      before do
        expect(Entity).to receive(:find).with(source.id).and_return(source)
        expect(Entity).to receive(:find).with(dest.id).and_return(dest)
        get :merge, params: { mode: 'execute', source: source.id, dest: dest.id }
      end

      it { is_expected.to respond_with(200) }
      it { is_expected.to render_template(:merge) }
      specify { expect(assigns(:merge_mode)).to eql 'execute' }
      specify { expect(assigns(:entity_merger)).to be_a EntityMerger }
    end
  end
end
