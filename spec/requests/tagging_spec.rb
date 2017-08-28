require 'rails_helper'

describe 'Tagging', :type => :request do
  let(:entity) { create(:org) }
  
  describe 'creating tags for an entity' do
    let(:user) { create_basic_user }  

    before(:each) do
      login_as(user, :scope => :user)
    end

    it 'creates new tags' do
      expect(Entity.find(entity.id).tags.length).to eql 0
      post "/entities/#{entity.id}/tags", :tags => { ids: ['1','2'] }
      expect(Entity.find(entity.id).tags.length).to eql 2
    end

    it 'redirects to entity page' do
      post "/entities/#{entity.id}/tags", :tags => { ids: ['1','2'] }
      expect(response).to have_http_status :accepted
      expect(JSON.parse(response.body)['redirect']).to include "/org/#{entity.id}"
    end
  end

  describe 'anon user' do
    it 'cannot create a tag' do
      expect(Entity.find(entity.id).tags.length).to eql 0
      post "/entities/#{entity.id}/tags", :tags => { ids: ['1','2'] }
      expect(Entity.find(entity.id).tags.length).to eql 0
      expect(response).to have_http_status 302
      expect(response.location).to include '/login'
    end
  end
end
