# describe 'api authentication' do
#     before(:all) do
#     @user = create_really_basic_user
#     @api_token = @user.create_api_token!
#     @auth_header = { 'Littlesis-Api-Token': @api_token.token }
#   end

#   after(:all) do
#     @user.delete
#     @api_token.delete
#   end

#   describe 'access control' do
#     let(:api_request) do
#       -> { get api_entity_path(create(:entity_person)) }
#     end

#     context 'when no api token provided' do
#       before { api_request.call }

#       specify { expect(response).to have_http_status :unauthorized }
#     end

#     context 'when no api token provided, but user is logged in' do
#       let(:user) { create_really_basic_user }

#       before do
#         login_as(user, :scope => :user)
#         api_request.call
#       end

#       after { logout(:user) }

#       specify { expect(response).to have_http_status :ok }
#     end
#   end
# end
