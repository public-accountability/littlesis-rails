describe 'SQL Function: network_map_sql' do
  it 'generates html link for a network map' do
    expect(ApplicationRecord.execute_one("SELECT network_map_link(123, 'My Title')"))
      .to eql '<a target="_blank" href="/maps/123-my-title">My Title</a>'
  end

  it 'removes "/" from link' do
    expect(ApplicationRecord.execute_one("SELECT network_map_link(123, 'My/Title')"))
      .to eql '<a target="_blank" href="/maps/123-my_title">My/Title</a>'
  end
end
