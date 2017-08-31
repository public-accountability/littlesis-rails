require 'rails_helper'

describe 'Tagging', :tagging_helper, :type => :request do
  let(:entity) { create(:org) }
  let(:list) { create(:list) }
  let(:user) { create_really_basic_user }
  let(:lister) { create_basic_user }
  let(:tags_params) { { tags: { ids: ['1', '2'] } } }
  let(:creating_entity_tags) {  -> { post "/entities/#{entity.id}/tags", tags_params } }
  let(:creating_list_tags) { -> { post "/lists/#{list.id}/tags", tags_params } }

  def redirects_to_login(r)
    expect(r).to have_http_status 302
    expect(r.location).to include '/login'
  end

  describe 'creating tags for an entity' do
    before(:each) do
      login_as(user, :scope => :user)
    end

    it 'creates new tags' do
      expect(creating_entity_tags)
        .to change { Entity.find(entity.id).tags.length }.by(2)
    end

    it 'redirects to entity page' do
      creating_entity_tags.call
      expect(response).to have_http_status :accepted
      expect(JSON.parse(response.body)['redirect']).to include "/org/#{entity.id}"
    end
  end

  describe 'anon user' do
    it 'cannot create a tag for an entity' do
      expect(creating_entity_tags).not_to change { Entity.find(entity.id).tags.length }
      redirects_to_login(response)
    end

    it 'cannot create a tag for an list' do
      expect(creating_list_tags).not_to change { List.find(list.id).tags.length }
      redirects_to_login(response)
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
  end
end
