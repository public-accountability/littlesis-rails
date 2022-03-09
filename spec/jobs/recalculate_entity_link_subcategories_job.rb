describe RecalculateEntityLinkSubcategoriesJob, type: :job do
  include ActiveJob::TestHelper
  let(:person) { create(:entity_person) }
  let(:org) { create(:entity_org) }

  specify do
    relationship = Relationship.create!(entity: person, related: org, category_id: Relationship::POSITION_CATEGORY)
    expect(relationship.links.find_by(is_reverse: false).subcategory).to eq 'positions'
    org.add_extension('Business')
    perform_enqueued_jobs
    expect(relationship.links.find_by(is_reverse: false).subcategory).to eq 'businesses'
  end
end
