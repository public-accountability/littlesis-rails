require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do

	describe 'routes' do
		it { should route(:get, '/documents/123/edit').to(action: :edit, id: '123') }
		it { should route(:patch, '/documents/123').to(action: :update, id: '123') }
	end

	describe "GET #edit" do
	    context 'as a logged-in user' do
	      login_user
	    	before do 
	    		@doc = build(:document)
      		expect(Document).to receive(:find).with('1').and_return(@doc)
	    		get :edit, id: 1
	    	end
	      it { should render_template 'edit' }
	    end

	    context 'without logging in' do
	    	before { get :edit, id: 1 }
	      it { should redirect_to '/login' }
	    end
	end

	describe "PATCH #update" do
    def valid_params
				{
					id: 1, 
					document: 
						{
	 					name: 'Da Googs',

	          excerpt: 'google google google',

	 					url: 'http://www.google.com',
	          publication_date: '2016-01-01',
	          ref_type: '1'
	        }
	      }
    end

    def invalid_params
			{
				id: 1, 
				document: {

          publication_date: '1234567890'
				}
      }
    end

		login_user

    before :each do

  		@doc = build(:document)
    	expect(Document).to receive(:find).with('1').and_return(@doc)
  		@request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
    end

		context 'with valid params' do
	  	before do 
	  		patch :update, valid_params

	  	end
	  	it { should redirect_to root_path }
		end

		context 'with invalid params' do
	  	before do 
	  		patch :update, invalid_params
	  	end
			it { should redirect_to edit_document_path(@doc) }

        expect(@doc.name).to eql 'Da Googs'
	  	end
	  	it { should redirect_to :back }
		end

		context 'with invalid params' do
	  	before { patch :update, invalid_params }
			it { should render_template 'edit' }

		end
	end

end
