require 'rails_helper'

describe CreateEditedEntityJob, type: :job do
  include ActiveJob::TestHelper

  let(:entity_version) { create(:entity_version) }
  let(:relationship_version) { create(:relationship_version) }

  it 'Entity Version: calls EditedEntity.create! with correct attributes' do
    expect(EditedEntity).to receive(:create!)
                              .with(user_id: entity_version.whodunnit.to_i,
                                    version_id: entity_version.id,
                                    entity_id: entity_version.entity1_id,
                                    created_at: entity_version.created_at)
                              .once

    perform_enqueued_jobs do
      CreateEditedEntityJob.perform_later(entity_version)
    end
  end

  it 'Relationship verison: creates two Edited Entities' do
    expect(EditedEntity).to receive(:create!)
                              .with(user_id: relationship_version.whodunnit.to_i,
                                    version_id: relationship_version.id,
                                    entity_id: relationship_version.entity1_id,
                                    created_at: relationship_version.created_at)
                              .once

    expect(EditedEntity).to receive(:create!)
                              .with(user_id: relationship_version.whodunnit.to_i,
                                    version_id: relationship_version.id,
                                    entity_id: relationship_version.entity2_id,
                                    created_at: relationship_version.created_at)
                              .once

    perform_enqueued_jobs do
      CreateEditedEntityJob.perform_later(relationship_version)
    end
  end
end
