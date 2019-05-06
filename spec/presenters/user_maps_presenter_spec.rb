describe UserMapsPresenter do
  let(:user) { create_really_basic_user }
  let(:network_maps) do
    Array.new(2) { create(:network_map, user_id: user.id) }
  end

  before { network_maps }

  it 'returns json string of network maps' do
    json = JSON.parse(UserMapsPresenter.new(user).render)
    expect(json.length).to eq 2
  end
end
