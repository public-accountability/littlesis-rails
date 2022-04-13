describe RoleUpgradeRequest do
  let(:user) { create_basic_user }
  let(:why) { Faker::Lorem.paragraph_by_chars }

  it 'creates request for editor by default' do
    request = RoleUpgradeRequest.create!(user: user, why: why)
    expect(request.role).to eq 'editor'
    expect(request.status).to eq 'pending'
  end

  it 'approving changes user role' do
    request = RoleUpgradeRequest.create!(user: user, why: why)
    expect { request.approve! }.to change { user.reload.role.name }
                                     .from('user').to('editor')

    expect(request.status).to eq 'approved'
  end

  it 'denying does not changes user role' do
    request = RoleUpgradeRequest.create!(user: user, why: why)
    expect { request.deny! }.not_to change { user.reload.role.name }
    expect(request.status).to eq 'denied'
  end
end
