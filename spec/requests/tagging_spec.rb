require 'rails_helper'

describe 'Tagging', :type => :request do

  describe 'creating tags for an entity' do
    let(:entity) { create(:org) }
    let(:user) { create_basic_user }

    before(:each) do
      login_as(user, :scope => :user)
    end

    it 'creates new tags' do
      expect(Entity.find(entity.id).tags.length).to eql 0
      post "/entities/#{entity.id}/tags", :tag => { ids: ['1','2'] }
      expect(Entity.find(entity.id).tags.length).to eql 2
    end
    
  end

  
end
