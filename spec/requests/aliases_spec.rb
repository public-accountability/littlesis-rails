describe 'aliases', :type => :request do
  include ::EntitiesHelper

  let(:entity) { create(:entity_org) }
  let(:user) { create_editor }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  describe '#create' do
    context 'with valid params' do
      let(:params) { { 'alias' => { 'name' => 'alt name', 'entity_id' => entity.id } } }

      before { entity }

      it 'creates a new Alias and redirects ' do
        expect { post "/aliases", params: params }.to change(Alias, :count).by(1)
        expect(response).to have_http_status :found
        expect(response).to redirect_to concretize_edit_entity_path(entity)
      end
    end

    context 'with invalid params' do
      let(:bad_params) { { 'alias' => { 'entity_id' => entity.id } } }

      before { entity }

      it 'does not create an alias' do
        expect { post "/aliases", params: bad_params }.not_to change(Alias, :count)
      end
    end
  end

  describe '#make_primary' do
    let(:entity) { build(:person) }
    let(:alias_instance) { build(:alias, entity: entity) }

    it 'redirects to edit entity path' do
      expect(Alias).to receive(:find).with('123').and_return(alias_instance)
      expect(alias_instance).to receive(:make_primary).once.and_return(true)
      patch "/aliases/123/make_primary", params: { id: 123 }
      expect(response).to redirect_to concretize_edit_entity_path(entity)
    end
  end

  describe '#destroy' do
    let!(:alias_instance) { create(:alias, entity_id: entity.id) }

    let(:delete_request) do
      -> { delete "/aliases/#{alias_instance.id}" }
    end

    it 'delete one alias' do
      expect(&delete_request).to change(Alias, :count).by(-1)
    end

    it 'reduces entity\'s aliases by one' do
      expect(&delete_request).to change { Entity.find(entity.id).aliases.count }.by(-1)
    end

    it 'redirects to edit entity path' do
      delete_request.call
      expect(response).to redirect_to concretize_edit_entity_path(entity)
    end

    context 'when alias is primary' do
      let(:alias_instance) do
        create(:alias, entity_id: entity.id, is_primary: true)
      end

      it 'does not delete the alias if it is the primary alias' do
        expect(&delete_request).not_to change(Alias, :count)
      end
    end
  end
end
