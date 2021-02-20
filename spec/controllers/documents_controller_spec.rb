describe DocumentsController, type: :controller do
  describe 'routes' do
    it { is_expected.to route(:get, '/documents/123/edit').to(action: :edit, id: '123') }
    it { is_expected.to route(:patch, '/documents/123').to(action: :update, id: '123') }
  end
end
