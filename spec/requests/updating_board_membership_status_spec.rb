describe 'updating a board membership relationship' do
  let(:user) { create_editor }
  let(:org) { create(:public_company_entity) }
  let(:person) { create(:entity_person) }
  let(:relationship) do
    Relationship.create!(category_id: 1, entity: person, related: org)
  end

  before { login_as(user, scope: :user) }

  specify do
    expect(relationship.links.find_by(is_reverse: true).subcategory).to eq "staff"
    expect(relationship.position.is_board).to be_nil

    patch relationship_path(relationship), params: {
      reference: { just_cleaning_up: 1, url: nil, name: nil },
      relationship: {
        start_date: '2024',
        position_attributes: {
          is_board: 'true',
          is_executive: nil,
          is_employee: nil,
          compensation: nil,
          id: relationship.position.id
        }
      }
    }

    expect(response).to redirect_to(relationship_path(relationship))
    relationship.reload
    expect(relationship.position.is_board).to be true
    expect(relationship.links.find_by(is_reverse: true).subcategory).to eq 'board_members'
  end
end
