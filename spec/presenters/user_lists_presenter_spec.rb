require 'rails_helper'

describe UserListsPresenter do
  let!(:user) { create_really_basic_user }
  let!(:lists) do
    [
      create(:open_list, creator_user_id: user.id)
        .tap { |l| l.update_column(:updated_at, 1.day.ago) },
      create(:closed_list, creator_user_id: user.id),
      create(:private_list, creator_user_id: user.id)
    ]
  end

  subject { UserListsPresenter.new(user) }

  it 'queries database for all lists' do
    expect(subject.length).to eql 3
  end

  it 'returns array of UserLists with correct data' do
    expect(subject[2]).to eql(
        UserListsPresenter::UserList.new(
          "/lists/#{lists[0].id}-open-list",
          'open list',
          'Open',
          1.day.ago.strftime('%F')
        )
      )
  end
end
