describe Lists::EntitiesController, type: :controller do
  describe 'routes' do
    it { is_expected.to route(:post, '/lists/1/entities').to(action: :create, list_id: 1) }
  end

  describe 'POST create' do
    let(:user) { create_basic_user }
    let(:list) { create(:list, name: 'Crying of Lot 49', last_user_id: user.id) }
    let(:params) do
      {
        list_id: list.id,
        entity: {
          name: 'Pierce Inverarity',
          blurb: 'Real estate mogul',
          primary_ext: 'Person',
          list_entities_attributes: [{
            list_id: list.id,
            last_user_id: user.id
          }]
        }
      }
    end

    context 'with restricted user' do
      before do
        sign_in(create(:user, is_restricted: true))
      end

      it 'does not add the entity to the list' do
        expect { post :create, params: params }
          .not_to change(list.list_entities, :count)

        expect(list.list_entities.count).to be 0
      end

      it 'redirects to the dashboard' do
        post :create, params: params
        expect(response).to redirect_to home_dashboard_path
        expect(flash[:notice]).to match 'Your account has been restricted'
      end
    end

    context 'without logged in user' do
      it 'does not add the entity to the list' do
        expect { post :create, params: params }
          .not_to change(list.list_entities, :count)

        expect(list.list_entities.count).to be 0
      end

      it 'redirects to the login page' do
        post :create, params: params
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    context 'with permitted user' do
      before do
        sign_in(user)
      end

      context 'with valid params' do
        it 'adds the entity to the list' do # rubocop:disable RSpec/ExampleLength
          expect { post :create, params: params }
            .to change(list.list_entities, :count).by(1)

          expect(list.list_entities.first.entity).to have_attributes(
            name: 'Pierce Inverarity',
            blurb: 'Real estate mogul',
            primary_ext: 'Person'
          )
        end

        it 'redirects to the list members page' do
          post :create, params: params
          expect(response).to redirect_to members_list_path(list)
          expect(flash[:notice]).to eq 'Pierce Inverarity added to Crying of Lot 49 list'
        end
      end

      context 'with invalid params' do
        let(:params) { { list_id: list.id, entity: { name: '' } } }

        it 'does not add the entity to the list' do
          expect { post :create, params: params }
            .not_to change(list.list_entities, :count)

          expect(list.list_entities.count).to be 0
        end

        it 'redirects to the list members page' do
          post :create, params: params
          expect(response).to redirect_to members_list_path(list)
          expect(flash[:notice]).to match 'Could not save entity'
        end
      end
    end
  end
end
