describe DocumentsController, type: :controller do
  describe 'routes' do
    it { should route(:get, '/documents/123/edit').to(action: :edit, id: '123') }
    it { should route(:patch, '/documents/123').to(action: :update, id: '123') }
  end

  describe "GET #edit" do
    context 'as a logged-in user' do
      login_user
      before do
        @doc = build(:document)
        expect(Document).to receive(:find).with(1).and_return(@doc)
        get :edit, params: { id: 1 }
      end
      it { should render_template 'edit' }
    end

    context 'without logging in' do
      before { get :edit, params: { id: 1 } }

      it 'redirects to /login' do
        expect(response).to have_http_status 302
        expect(response.location).to include '/login'
      end
    end
  end

  describe "PATCH #update" do
    login_user
    let(:document_params) do
      attributes_for(:document)
        .merge(excerpt: Faker::Lorem.sentence, publication_date: '2016-01-01', ref_type: '1')
    end

    before :each do
      @doc = create(:document, document_params)
      @request.env['HTTP_REFERER'] = 'http://test.com/sessions/new'
    end

    context 'with valid params' do
      before do
        patch :update, params: { id: @doc.id, document: document_params.merge(publication_date: '2017-01-01') }
      end
      it { should redirect_to home_dashboard_path }

      it 'changes the publication date' do
        expect(@doc.reload.publication_date).to eql '2017-01-01'
      end
    end

    context 'with invalid params' do
      before do
        patch :update,
              params: {
                id: @doc.id,
                document: document_params.merge(publication_date: 'THIS IS NOT A DATE')
              }
      end

      it { should redirect_to edit_document_path(@doc) }

      it 'does not change the document name' do
        expect(@doc.reload.publication_date).to eql '2016-01-01'
      end
    end
  end
end
