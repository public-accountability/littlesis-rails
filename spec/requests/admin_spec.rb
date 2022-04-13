describe 'Admin' do
  describe 'setting role' do
    let(:admin) { create_admin_user }
    let(:user) { create_basic_user }

    before { login_as(admin, :scope => :user) }

    after { logout(:user) }

    it 'changes role' do
      expect(user.role.name).to eq 'user'
      post "/admin/users/#{user.id}/set_role", params: { role: 'editor' }
      expect(user.reload.role.name).to eq 'editor'
      expect(JSON.parse(response.body)).to eq({ 'status' => 'ok', 'role' => 'editor' })
    end
  end
end
