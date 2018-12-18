# frozen_string_literal: true

# rubocop:disable RSpec/InstanceVariable

require 'rails_helper'

describe 'SQL function: recent_entity_edits' do
  let(:user) { create_basic_user }

  before do
    @person = create(:entity_person)

    with_versioning_for(user) do
      @org = create(:entity_org)
      @relationship = Relationship.create!(category_id: 1,
                                           entity: @person,
                                           related: @org)
    end
  end

  it 'crafts json array of versions' do
    expect(JSON.parse(ApplicationRecord.execute_one("SELECT recent_entity_edits(10)")))
      .to eq([
               {
                 'entity_id' => @person.id,
                 'version_id' => @relationship.versions.last.id,
                 'item_type' => 'Relationship',
                 'item_id' => @relationship.id,
                 'user_id' => user.id,
                 'created_at' => @relationship.versions.last.created_at.strftime('%Y-%m-%d %H:%M:%S')
               },
               {
                 'entity_id' => @org.id,
                 'version_id' => @relationship.versions.last.id,
                 'item_type' => 'Relationship',
                 'item_id' => @relationship.id,
                 'user_id' => user.id,
                 'created_at' => @relationship.versions.last.created_at.strftime('%Y-%m-%d %H:%M:%S')
               },
               {
                 'entity_id' => @org.id,
                 'version_id' => @org.versions.last.id,
                 'item_type' => 'Entity',
                 'item_id' => @org.id,
                 'user_id' => user.id,
                 'created_at' => @org.versions.last.created_at.strftime('%Y-%m-%d %H:%M:%S')
               }
             ])
  end
end

# rubocop:enable RSpec/InstanceVariable
