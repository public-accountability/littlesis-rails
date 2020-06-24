describe 'External Relationships matcher' do
  let(:external_relationship) { create(:external_relationship_schedule_a) }

  before do
    login_as(create_basic_user, scope: :user)
    allow(EntityMatcher).to receive(:find_matches_for_org).and_return([])
    visit external_relationship_path(external_relationship)
  end

  after { logout(:user) }

  it 'shows relationships details' do
    expect(page.html).to include 'Ck Petroleum'
  end

  it 'has matching tools for both entities' do
    page_has_selector 'div.entity-matcher', count: 2
  end
end
