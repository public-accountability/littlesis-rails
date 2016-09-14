require 'rails_helper'

describe ReferencesController, type: :controller do

  before(:each) do 
    DatabaseCleaner.start
  end

  after(:each) do 
    DatabaseCleaner.clean
  end

  
  describe 'auth' do 
    it 'redirects to login if user is not logged in' do 
      post(:create)
      expect(response).to have_http_status(302)
    end
  end

  describe 'POST /reference' do 
    login_user
    
    before(:all) do 
      @post_data = {data: {
                      object_id: 666,
                      source: 'interesting.net',
                      name: 'a website',
                      object_model: "Relationship",
                      excerpt: "so and so said blah blah blah",
                      ref_type: 1}
                   }
    end

    before do 
      allow(Relationship).to receive(:find) { double('relationship').as_null_object  }
    end
    
    it 'creates a new reference' do 
      expect { post(:create, @post_data) }.to change(Reference, :count).by(1)

      expect(Reference.last.object_model).to eql "Relationship"
      expect(Reference.last.source).to eql "interesting.net"
      expect(Reference.last.name).to eql "a website"
      expect(Reference.last.object_id).to eql 666
      expect(Reference.last.last_user_id). to eql SfGuardUser.last.id

      expect(response).to have_http_status(:created)
    end

    it 'creates a new ReferenceExcerpt if there is an excerpt' do 
      expect { post(:create, @post_data) }.to change(ReferenceExcerpt, :count).by(1)
      expect(ReferenceExcerpt.last.reference).to eql Reference.last
      expect(Reference.last.excerpt).to eql "so and so said blah blah blah"
    end

    it 'does not create new ReferenceExcept if there is a blank excerpt' do 
      expect { 
        post(:create, {data: {object_id: 666,
                              source: 'interesting.net',
                              name: 'a website',
                              object_model: "Relationship",
                              excerpt: "",
                              ref_type: 1 }}) 
      }.to change(ReferenceExcerpt, :count).by(0)
      
      expect(Reference.last.excerpt).to be_nil
    end

    it 'does not create new ReferenceExcept if excerpt is not sent' do 
      expect { 
        post(:create, {data: {object_id: 666,
                              source: 'interesting.net',
                              name: 'a website',
                              object_model: "Relationship",
                              ref_type: 1 }}) 
      }.to change(ReferenceExcerpt, :count).by(0)
      
      expect(Reference.last.excerpt).to be_nil
    end

    it 'updates updated_at field of the relationship' do 
      rel = double("relationship")
      expect(Relationship).to receive(:find).with(666).and_return(rel)
      expect(rel).to receive(:touch)
      post(:create, @post_data)
    end

    it 'returns json of errors if reference is not valid' do 
      post(:create, {data: {
                       object_id: 666,
                       object_model: "Relationship",
                       ref_type: 1}
                    })
      body = JSON.parse(response.body)

      expect(response).to have_http_status(400)
      expect(body['errors']['source']).to eql ["can't be blank"]
    end

  end

  describe 'DELETE /reference' do 
    login_user
    
    before(:all) do 
     @ref = create(:ref, source: 'link', object_id: 1234) 
    end
    
    it 'deletes a reference' do 
      expect { 
        delete :destroy, id: @ref 
      }.to change(Reference, :count).by(-1)
      
      expect(response).to have_http_status(200)
    end
    
    it 'bad_requests for bad ids' do 
      delete :destroy, id: 8888
      expect(response).to have_http_status(400)
    end
    
  end

end
