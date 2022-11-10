describe PermissionPassesController, type: :controller do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create_admin_user }
  let!(:pass) { create(:permission_pass, creator: admin_user, role: User.roles['editor']) }

  let(:params) do
    {
      "permission_pass" => {
        "event_name" => "Some workshop",
        "valid_from(1i)" => "2020",
        "valid_from(2i)" => "7",
        "valid_from(3i)" => "9",
        "valid_from(4i)" => "12",
        "valid_from(5i)" => "29",
        "valid_to(1i)" => "2020",
        "valid_to(2i)" => "7",
        "valid_to(3i)" => "9",
        "valid_to(4i)" => "14",
        "valid_to(5i)" => "29",
        "role" => 4
      }
    }
  end

  before do
    controller.default_url_options[:host] = 'test.host'
  end

  [:index, :new].each do |action|
    describe "GET ##{action}" do
      context 'with a logged in admin' do
        it 'renders the page' do
          sign_in(admin_user)
          get action
          expect(response).to render_template(action)
        end
      end

      context 'with a regular user' do
        it 'forbids access' do
          sign_in(regular_user)
          get action
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe "POST #create" do
    context 'with a logged in admin' do
      it 'creates the pass' do
        sign_in(admin_user)
        post :create, params: params
        expect(response).to redirect_to(action: :index)
      end
    end

    context 'with a regular user' do
      it 'forbids access' do
        sign_in(regular_user)
        post :create, params: params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH #update" do
    context 'with a logged in admin' do
      it 'updates the pass' do
        sign_in(admin_user)
        patch :update, params: params.merge(id: pass.id)
        expect(response).to redirect_to(action: :index)
      end
    end

    context 'with a regular user' do
      it 'forbids access' do
        sign_in(regular_user)
        patch :update, params: params.merge(id: pass.id)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE #destroy" do
    context 'with a logged in admin' do
      it 'deletes the pass' do
        sign_in(admin_user)
        delete :destroy, params: { id: pass.id }
        expect(response).to redirect_to(action: :index)
      end
    end

    context 'with a regular user' do
      it 'forbids access' do
        sign_in(regular_user)
        delete :destroy, params: { id: pass.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET #edit" do
    context 'with a logged in admin' do
      it 'renders the page' do
        sign_in(admin_user)
        get :edit, params: { id: pass.id }
        expect(response).to render_template(:edit)
      end
    end

    context 'with a regular user' do
      it 'forbids access' do
        sign_in(regular_user)
        get :edit, params: { id: pass.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET #apply' do
    context 'with a regular user' do
      before do
        request.env['HTTP_REFERER'] = 'http://test.host/example'
      end

      it 'sets the abilities and redirects to referer' do
        sign_in(regular_user)
        expect(regular_user.role.name).to eq 'user'
        get :apply, params: { permission_pass_id: pass.id }
        expect(regular_user.reload.role.name).to eq 'editor'
        expect(response).to redirect_to('http://test.host/example')
      end
    end
  end
end
