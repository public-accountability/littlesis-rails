describe "entities/link", type: :view do
  let(:entity) { build(:org) }
  let(:person) { build(:person) }
  let(:other_person) { build(:person, name: 'other person') }

  let(:relationship_notes) { nil }

  let(:rel_between_entity_and_person) do
    build(:generic_relationship, entity: entity, related: person, is_current: false, notes: relationship_notes)
  end

  let(:rel_between_entity_and_other_person) do
    build(:generic_relationship, entity: entity, related: other_person)
  end

  let(:link1) do
    build(:link, entity: entity, related: person, relationship: rel_between_entity_and_person, category_id: 12)
  end

  let(:link2) do
    build(:link, entity: entity, related: other_person, relationship: rel_between_entity_and_other_person, category_id: 12)
  end

  let(:links_group) { LinksGroup.new([link1, link2], 'miscellaneous', 'Other Affiliations') }

  before do
    render partial: 'entities/link', locals: { link: links_group.links[1] }
  end

  it 'has correct div layout' do
    css 'div.relationship-section'
    css 'div.related_entity_relationship span a'
  end

  it 'has relationship title' do
    expect(rendered).to match(/Affiliation \(past\)/)
  end

  context 'when relationship has notes' do
    let(:relationship_notes) { 'foobar' }

    specify do
      expect(rendered).to match(/Affiliation \(past\)\*/)
    end
  end

  context 'when invalid date' do
    let(:rel_between_entity_and_person) do
      build(:generic_relationship, entity: entity, related: person, start_date: '1999')
    end

    it 'still renders correctly' do
      css 'div.relationship-section'
      css 'div.related_entity_relationship span a'
    end
  end
end
