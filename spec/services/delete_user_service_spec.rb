describe DeleteUserService do
  specify do
    user = create_basic_user_with_profile
    map_ids = 2.times.map { create(:network_map, user: user).id }
    list_id = create(:private_list, user: user).id
    expect(user.deleted?).to be false
    DeleteUserService.run(user)
    expect(user.deleted?).to be true
    expect(NetworkMap.where(id: map_ids).count).to eq 0
    expect(List.find_by(id: list_id)).to be nil
  end
end
