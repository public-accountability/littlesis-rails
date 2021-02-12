# frozen_string_literal: true

# rubocop:disable RSpec/InstanceVariable

describe 'SQL function: recent_entity_edits' do
  let(:user) { create_basic_user }
  let(:user2) { create_basic_user }

  before do
    @person = create(:entity_person)

    with_versioning_for(user) do
      @org = create(:entity_org)
      @relationship = Relationship.create!(category_id: 1,
                                           entity: @person,
                                           related: @org)
    end

    with_versioning_for(user2) do
      @person_created_by_user2 = create(:entity_person)
    end
  end

  it 'crafts json array of versions' do
    expect(JSON.parse(ApplicationRecord.execute_one("SELECT recent_entity_edits(10, NULL)")))
      .to eq([
               {
                 'entity_id' => @person_created_by_user2.id,
                 'version_id' => @person_created_by_user2.versions.last.id,
                 'item_type' => 'Entity',
                 'item_id' => @person_created_by_user2.id,
                 'user_id' => user2.id,
                 'created_at' => @person_created_by_user2.versions.last.created_at.strftime('%Y-%m-%dT%H:%M:%S.%6N')
               },
               {
                 'entity_id' => @person.id,
                 'version_id' => @relationship.versions.last.id,
                 'item_type' => 'Relationship',
                 'item_id' => @relationship.id,
                 'user_id' => user.id,
                 'created_at' => @relationship.versions.last.created_at.strftime('%Y-%m-%dT%H:%M:%S.%6N')
               },
               {
                 'entity_id' => @org.id,
                 'version_id' => @relationship.versions.last.id,
                 'item_type' => 'Relationship',
                 'item_id' => @relationship.id,
                 'user_id' => user.id,
                 'created_at' => @relationship.versions.last.created_at.strftime('%Y-%m-%dT%H:%M:%S.%6N')
               },
               {
                 'entity_id' => @org.id,
                 'version_id' => @org.versions.last.id,
                 'item_type' => 'Entity',
                 'item_id' => @org.id,
                 'user_id' => user.id,
                 'created_at' => @org.versions.last.created_at.strftime('%Y-%m-%dT%H:%M:%S.%6N')
               }
             ])
  end

  it 'returns only 3 edits for user1' do
    expect(
      JSON.parse(ApplicationRecord.execute_one("SELECT recent_entity_edits(10, '#{user.id}')")).length
    ).to eq 3
  end

  it 'produces correct result for user2' do
    expect(
      JSON.parse(ApplicationRecord.execute_one("SELECT recent_entity_edits(10, '#{user2.id}')"))
    ).to eq([
              {
                'entity_id' => @person_created_by_user2.id,
                'version_id' => @person_created_by_user2.versions.last.id,
                'item_type' => 'Entity',
                'item_id' => @person_created_by_user2.id,
                'user_id' => user2.id,
                'created_at' => @person_created_by_user2.versions.last.created_at.strftime('%Y-%m-%dT%H:%M:%S.%6N')
              }
            ])
  end
end

# rubocop:enable RSpec/InstanceVariable
