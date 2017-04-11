require 'rails_helper'

describe AliasesController, type: :controller do
  it { should use_before_action(:authenticate_user!) }
  it { should route(:patch, '/aliases/123').to(action: :update, id: 123) }
  it { should route(:post, '/aliases').to(action: :create) }
  it { should route(:delete, '/aliases/123').to(action: :destroy, id: 123) }

  describe '#create' do
    login_user
    before(:all)  { @entity = create(:org) }

    context 'with valid params' do
      def new_alias_post
        post :create, { 'alias' => { 'name' => 'alt name', 'entity_id' => @entity.id } }
      end

      it 'creates a new Alias' do
        expect { new_alias_post }.to change { Alias.count }.by(1)
      end

      it 'redirects to edit entity path' do
        new_alias_post
        expect(response).to have_http_status 302
        expect(response).to redirect_to edit_entity_path(@entity)
        expect(controller).not_to set_flash[:alert]
      end
    end

    context 'with invalid params' do
      let(:bad_params) { { 'alias' => { 'entity_id' => @entity.id } } }

      it 'does not create an alias' do
        expect { post :create, bad_params }.not_to change { Alias.count }
      end

      it 'redirects to edit entity path' do
        post :create, bad_params
        expect(response).to have_http_status 302
      end

      it 'sets flash' do
        post :create, bad_params
        expect(controller).to set_flash[:alert]
      end
    end
  end
end
