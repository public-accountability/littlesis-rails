require 'rails_helper'

describe ReferencesController, type: :controller do

  before(:each) do 
    DatabaseCleaner.start
  end

  after(:each) do 
    DatabaseCleaner.clean
  end

  describe 'POST /reference' do 
    login_user
    
    it 'creates a new reference' do 
      expect {
        post(:create, {object_id: 666,
                       source: 'interesting.net',
                       name: 'a website',
                       object_model: "Relationship",
                       ref_type: 1})
      }.to change(Reference, :count).by(1)
      
      expect(Reference.last.object_model).to eql "Relationship"
      expect(Reference.last.source).to eql "interesting.net"
      expect(Reference.last.name).to eql "a website"
      expect(Reference.last.object_id).to eql 666
      expect(Reference.last.last_user_id). to eql SfGuardUser.last.id
    end
  end

end
