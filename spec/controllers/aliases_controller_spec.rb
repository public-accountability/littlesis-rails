describe AliasesController, type: :controller do
  include ::EntitiesHelper

  let(:entity) { create(:entity_org) }

  it { is_expected.to use_before_action(:authenticate_user!) }
  it { is_expected.to route(:patch, '/aliases/123').to(action: :update, id: 123) }
  it { is_expected.to route(:post, '/aliases').to(action: :create) }
  it { is_expected.to route(:delete, '/aliases/123').to(action: :destroy, id: 123) }
  it { is_expected.to route(:patch, '/aliases/123/make_primary').to(action: :make_primary, id: 123) }

  describe '#create' do
    login_user

    context 'with valid params' do
      let(:params) { { 'alias' => { 'name' => 'alt name', 'entity_id' => entity.id } } }
      let(:new_alias_post) { proc { post :create, params: params } }

      before { entity }

      it 'creates a new Alias' do
        expect { new_alias_post.call }.to change { Alias.count }.by(1)
      end

      it 'redirects to edit entity path' do
        new_alias_post.call
        expect(response).to have_http_status 302
        expect(response).to redirect_to concretize_edit_entity_path(entity)
        expect(controller).not_to set_flash[:alert]
      end
    end

    context 'with invalid params' do
      let(:bad_params) { { 'alias' => { 'entity_id' => entity.id } } }

      it 'does not create an alias' do
        entity
        expect { post :create, params: bad_params }.not_to change(Alias, :count)
      end

      it 'redirects to edit entity path' do
        post :create, params: bad_params
        expect(response).to have_http_status 302
      end

      it 'sets flash' do
        post :create, params: bad_params
        expect(controller).to set_flash[:alert]
      end
    end
  end

  describe '#make_primary' do
    login_user

    let(:entity) { build(:person) }

    it 'redirects to edit entity path' do
      alias_instance = build(:alias, entity: entity)
      expect(Alias).to receive(:find).with('123').and_return(alias_instance)
      expect(alias_instance).to receive(:make_primary).once.and_return(true)
      patch :make_primary, params: { id: 123 }
      expect(response).to redirect_to concretize_edit_entity_path(entity)
    end
  end

  describe '#destroy' do
    login_user

    let!(:alias_instance) { create(:alias, entity_id: entity.id) }

    it 'delete one alias' do
      expect { delete :destroy, params: { id: alias_instance.id } }.to change(Alias, :count).by(-1)
    end

    it 'reduces entity\'s aliases by one' do
      expect { delete :destroy, params: { id: alias_instance.id } }
        .to change { Entity.find(entity.id).aliases.count }.by(-1)
    end

    it 'redirects to edit entity path' do
      delete :destroy, params: { id: alias_instance.id }
      expect(response).to redirect_to concretize_edit_entity_path(entity)
    end

    context 'when alias is primary' do
      let(:alias_instance) do
        create(:alias, entity_id: entity.id, is_primary: true)
      end

      it 'does not delete the alias if it is the primary alias' do
        expect { delete :destroy, params: { id: alias_instance.id } }.not_to change(Alias, :count)
      end
    end
  end
end
