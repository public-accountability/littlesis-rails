describe 'adding to lists' do
  let(:user) { create_collaborator }
  let(:public_company) { create(:public_company_entity) }
  let(:params) { { entity_id: public_company.id } }
  let(:path) { list_list_entities_path(list_id: list.id) }

  before do
    login_as(user, :scope => :user)
  end

  after do
    logout(:user)
  end

  context 'when the list is private to the signed in user' do
    let(:list) { create(:list, user: user, access: Permissions::ACCESS_PRIVATE) }

    it 'adds the entity to the list' do
      expect { post path, params: params }.to change(list.entities, :count).by(1)
    end
  end

  context 'when the list is private to someone else' do
    let(:list) { create(:list, user: create_editor, access: Permissions::ACCESS_PRIVATE) }

    it 'is forbidden' do
      post path, params: params
      expect(response).to be_forbidden
    end

    it "doesn't add the entity to the list" do
      expect { post path, params: params }.not_to change(list.entities, :count)
    end
  end

  context 'when the list is open for edits' do
    let(:list) { create(:list, access: Permissions::ACCESS_OPEN) }

    it 'adds the entity to the list' do
      expect { post path, params: params }.to change(list.entities, :count).by(1)
    end
  end

  context 'when the list is closed' do
    let(:list) { create(:list, access: Permissions::ACCESS_CLOSED) }

    it 'is forbidden' do
      post path, params: params
      expect(response).to be_forbidden
    end

    it "doesn't add the entity to the list" do
      expect { post path, params: params }.not_to change(list.entities, :count)
    end
  end

  context "when the user doesn't have list permissions" do
    let(:user) { create_editor }
    let(:list) { create(:list, access: Permissions::ACCESS_OPEN) }

    it 'is forbidden' do
      post path, params: params
      expect(response).to be_forbidden
    end

    it "doesn't add the entity to the list" do
      expect { post path, params: params }.not_to change(list.entities, :count)
    end
  end

  context "when there is no signed in user" do
    before { logout(:user) }

    let(:list) { create(:list, access: Permissions::ACCESS_OPEN) }

    it "doesn't add the entity to the list" do
      expect { post path, params: params }.not_to change(list.entities, :count)
      expect(response).not_to be_ok
    end
  end
end
