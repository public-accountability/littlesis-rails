describe Lists::InterlocksController, type: :controller do
  context 'with a list of people' do
    let(:list) { create(:list) }
    let(:person) { create(:entity_person) }

    before do
      ListEntity.create!(list_id: list.id, entity_id: person.id)
      Link.refresh
    end

    describe 'interlocks' do
      before do
        get :index, params: { list_id: list.id }
      end

      it { is_expected.to respond_with(:success) }
    end

    describe 'giving' do
      before do
        get :show, params: { list_id: list.id, interlocks_tab: :giving }
      end

      it { is_expected.to respond_with(:success) }
    end

    describe 'funding' do
      before do
        get :show, params: { list_id: list.id, interlocks_tab: :funding }
      end

      it { is_expected.to respond_with(:success) }
    end

    describe 'government' do
      before do
        get :show, params: { list_id: list.id, interlocks_tab: :government }
      end

      it { is_expected.to respond_with(:success) }
    end
  end
end
