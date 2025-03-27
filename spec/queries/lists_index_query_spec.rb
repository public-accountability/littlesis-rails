describe ListsIndexQuery, :sphinx do
  let(:entity1) { create(:entity_person) }
  let(:entity2) { create(:entity_person) }
  let(:entity3) { create(:entity_person) }
  let(:other_person) { create_editor }
  let(:list_owner) { create_editor }
  let(:private_list) { create(:list, name: "interesting list", access: Permissions::ACCESS_PRIVATE, creator_user_id: list_owner.id) }
  let(:public_list) { create(:list, name: "cool list", access: Permissions::ACCESS_OPEN, creator_user_id: list_owner.id) }

  before do
    setup_sphinx
    private_list; public_list;
    create(:list_entity, list: private_list, entity: entity1)
    create(:list_entity, list: private_list, entity: entity2)
    create(:list_entity, list: public_list, entity: entity1)
    create(:list_entity, list: public_list, entity: entity2)
    create(:list_entity, list: public_list, entity: entity3)
  end

  after do
    teardown_sphinx
  end

  it 'finds list by name, skipping private' do
    interesting_result = ListsIndexQuery.new.run('interesting')
    expect(interesting_result.length).to eq 0
    cool_result = ListsIndexQuery.new.run('cool')
    expect(cool_result.length).to eq 1
    list_result = ListsIndexQuery.new.run('list')
    expect(list_result.length).to eq 1
    list_result_for_creator = ListsIndexQuery.new(user_id: list_owner.id).run('list')
    expect(list_result_for_creator.length).to eq 2
  end

  it 'finds lists by entity' do
    result = ListsIndexQuery.new.for_entity(entity1).run
    expect(result.length).to eq 1
    expect(result.first).to eq public_list
  end

  it 'can find entities on private lists' do
    result = ListsIndexQuery.new(user_id: list_owner.id).for_entity(entity1).run
    expect(result.length).to eq 2
  end
end
