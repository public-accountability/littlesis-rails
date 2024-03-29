describe EntitiesController, type: :controller do
  it { is_expected.to use_before_action(:authenticate_user!) }
  it { is_expected.to use_before_action(:set_entity) }

  describe 'routes' do
    it { is_expected.to route(:get, '/entities/1').to(action: :show, id: 1) }
    it { is_expected.to route(:get, '/entities/1/interlocks').to(action: :show, id: 1, active_tab: :interlocks) }
    it { is_expected.to route(:get, '/entities/1/giving').to(action: :show, id: 1, active_tab: :giving) }
    it { is_expected.to route(:get, '/entities/1/datatable').to(action: :datatable, id: 1) }
    it { is_expected.to route(:get, '/entities/1/add_relationship').to(action: :add_relationship, id: 1) }
    it { is_expected.to route(:get, '/entities/new').to(action: :new) }
    it { is_expected.to route(:post, '/entities').to(action: :create) }
    it { is_expected.to route(:post, '/entities/bulk').to(action: :create_bulk) }
    it { is_expected.to route(:get, '/entities/1/edit').to(action: :edit, id: 1) }
    it { is_expected.to route(:patch, '/entities/1').to(action: :update, id: 1) }
    it { is_expected.to route(:delete, '/entities/1').to(action: :destroy, id: 1) }
    it { is_expected.to route(:get, '/entities/1/political').to(action: :political, id: 1) }
    it { is_expected.to route(:get, '/entities/1/references').to(action: :references, id: 1) }
    it { is_expected.to route(:post, '/entities/1/tags').to(action: :tags, id: 1) }

    it do
      is_expected.to route(:get, '/entities/1/grouped_links/donations/3')
                       .to(action: :grouped_links, id: 1, subcategory: 'donations', page: 3)
    end

    it do
      is_expected.not_to route(:get, '/entities/1/grouped_links/waves/3')
                           .to(action: :grouped_links, id: 1, subcategory: 'waves', page: 3)
    end

    context 'with primary extensions' do
      let(:org) { build(:org) }
      let(:person) { build(:person) }

      specify do
        expect(:get => "/org/#{org.to_param}").to route_to(controller: "entities", action: "show", id: org.to_param)
        expect(:get => "/person/#{person.to_param}").to route_to(controller: "entities", action: "show", id: person.to_param)
      end
    end

    it 'routes names with periods' do
      org = build(:org, name: "X.Y.Z.")
      expect(:get => "/entities/#{org.to_param}").to route_to(controller: "entities", action: "show", id: org.to_param)
    end
  end

  describe 'GETs' do
    let(:entity) { create(:entity_org) }

    describe '/entity/id' do
      before { get :show, params: { id: entity.id } }

      it { is_expected.to render_template(:profile) }
    end

    describe 'entity/id/datatable' do
      before { get :datatable, params: { id: entity.id } }

      it { is_expected.to respond_with 302 }
    end
  end

  describe '#edit' do
    describe 'when user is not logged in' do
      let(:org) { create(:entity_org) }

      before { get :edit, params: { id: org.id } }

      it { is_expected.to respond_with 302 }
    end
  end
end
