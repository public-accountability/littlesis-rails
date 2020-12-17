describe DocumentsController, type: :controller do
  describe 'routes' do
    it { is_expected.to route(:get, '/documents/123/edit').to(action: :edit, id: '123') }
    it { is_expected.to route(:patch, '/documents/123').to(action: :update, id: '123') }
  end

  describe "GET #edit" do
    context 'when logged in' do
      login_user

      let(:doc) { build(:document) }

      before do
        allow(Document).to receive(:find).with(1).and_return(doc)
        get :edit, params: { id: 1 }
      end

      it { is_expected.to render_template 'edit' }
    end

    context 'when logged out' do
      before { get :edit, params: { id: 1 } }

      it 'redirects to /login' do
        expect(response).to have_http_status :found
        expect(response.location).to include '/login'
      end
    end
  end

  describe "PATCH #update" do
    login_user

    let(:document) do
      create(:document, excerpt: Faker::Lorem.sentence, publication_date: '2016-01-01')
    end

    context 'with valid params' do
      before do
        patch :update, params: { id: document.id, document: { publication_date: '2017-01-01' } }
      end

      it { is_expected.to redirect_to home_dashboard_path }

      it 'changes the publication date' do
        expect(document.reload.publication_date).to eql '2017-01-01'
      end
    end

    context 'with invalid params' do
      before do
        patch :update, params: { id: document.id,
                                 document: { publication_date: 'THIS IS NOT A DATE' } }
      end

      it { is_expected.to redirect_to edit_document_path(document) }

      it 'does not change the document name' do
        expect(document.reload.publication_date).to eq '2016-01-01'
      end
    end
  end
end
