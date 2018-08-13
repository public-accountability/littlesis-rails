require 'rails_helper'

describe UserMapsPresenter do
  let!(:user) { create_really_basic_user }
  let!(:network_maps) do
    Array.new(2) { create(:network_map, user_id: user.sf_guard_user_id) }
  end
  subject { UserMapsPresenter.new(user) }

  it 'returns json string of network maps' do
    json = JSON.parse(subject.render)
    expect(json.length).to eql 2
  end
end
