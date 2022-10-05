describe 'Tagging', :tag_helper, :tagging_helper, :type => :request do
  before do
    TagSpecHelper::TAGS.each { |t| Tag.create!(t) }
  end

  let(:entity) { create(:entity_org) }
  let(:list) { create(:list) }
  let(:relationship) { Relationship.create!(category_id: 12, entity: create(:entity_person), related: create(:entity_org)) }
  let(:user) { create_editor }
  let(:lister) { create_collaborator }
  let(:admin) { create_admin_user }
  let(:tags_params) { { tags: { ids: ['1', '2'] } } }
  let(:creating_entity_tags) {  -> { post "/org/#{entity.to_param}/tags", xhr: true, params: tags_params } }
  let(:creating_list_tags) { -> { post "/lists/#{list.id}/tags", xhr: true, params: tags_params } }
  let(:creating_relationship_tags) { -> { post "/relationships/#{relationship.id}/tags", xhr: true, params: tags_params } }

  def redirects_to_login(r)
    expect(r).to have_http_status 302
    expect(r.location).to include '/login'
  end

  describe 'anon user' do
    it 'cannot create a tag for an entity' do
      expect { post "/org/#{entity.to_param}/tags", params: tags_params }
        .not_to change { Entity.find(entity.id).tags.length }

      redirects_to_login(response)
    end

    it 'cannot create a tag for an list' do
      expect { post "/lists/#{list.id}/tags", params: tags_params }
        .not_to change { List.find(list.id).tags.length }

      redirects_to_login(response)
    end

    it 'cannot create a tag for a relationship' do
      expect { post "/relationships/#{relationship.id}/tags", params: tags_params }
        .not_to change { Relationship.find(relationship.id).tags.length }

      redirects_to_login(response)
    end
  end

  describe 'creating tags for an entity' do
    before(:each) { login_as(user, :scope => :user) }

    it 'creates new tags' do
      expect(&creating_entity_tags)
        .to change { Entity.find(entity.id).tags.length }.by(2)
    end

    it 'redirects to entity page' do
      creating_entity_tags.call
      expect(response).to have_http_status :accepted
      expect(JSON.parse(response.body)['redirect']).to include "/org/#{entity.id}"
    end
  end

  describe 'creating tags for a relationship' do
    before(:each) { login_as(user, :scope => :user) }

    it 'creates new tags' do
      expect(&creating_relationship_tags)
        .to change { Relationship.find(relationship.id).tags.length }.by(2)
    end

    it 'redirects to relationship page' do
      creating_relationship_tags.call
      expect(response).to have_http_status :accepted
      expect(JSON.parse(response.body)['redirect']).to include "/relationships/#{relationship.id}"
    end
  end

  describe 'creating tags for a list' do
    context 'When the list is open and the user is the owner' do
      let(:list) { create(:open_list, creator_user_id: user.id) }
      before { login_as(user, :scope => :user) }

      creates_tags_and_tells_client_to_redirect
    end

    context 'When the list is open and the user is a lister' do
      let(:list) { create(:open_list, creator_user_id: user.id) }
      before { login_as(lister, :scope => :user) }

      denies_creating_tags_for_lists
    end

    context 'When the list is closed and the user is the owner' do
      let(:list) { create(:closed_list, creator_user_id: user.id) }
      before { login_as(user, :scope => :user) }

      creates_tags_and_tells_client_to_redirect
    end

    context 'When the list is private and the user is the list owner' do
      let(:list) { create(:private_list, creator_user_id: user.id) }
      before { login_as(user, :scope => :user) }

      creates_tags_and_tells_client_to_redirect
    end

    context 'when the list is private the the user is NOT the list owner' do
      let(:list) { create(:private_list, creator_user_id: user.id) }
      before { login_as(lister, :scope => :user) }

      denies_creating_tags_for_lists
    end

    context 'when the list is closed and the user is an admin' do
      let(:list) { create(:closed_list, creator_user_id: user.id) }
      before { login_as(admin, :scope => :user) }

      creates_tags_and_tells_client_to_redirect
    end
  end

  describe 'requesting a new tag' do
    before { login_as(user, :scope => :user) }

    after { logout(:user) }

    let(:request_params) do
      {
        'tag_name' => 'a',
        'tag_description' => 'b',
        'tag_additional' => 'c'
      }
    end

    it 'sends notification email' do
      expect(NotificationMailer).to receive(:tag_request_email)
                                      .once
                                      .with(user, request_params)
                                      .and_return(double(:deliver_later => nil))

      post tags_request_path, params: request_params
    end

    it 'redirects to homepage' do
      post tags_request_path, params: request_params
      expect(response).to have_http_status 302
    end
  end
end
