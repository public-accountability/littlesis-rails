require 'rails_helper'

describe CreateEditedEntityJob, type: :job do
  include ActiveJob::TestHelper

  let(:entity_version) { create(:entity_version) }
  let(:relationship_version) { create(:relationship_version) }

  before do
    entity_version
    relationship_version
  end

  it 'Entity Version: calls EditedEntity.create! with correct attributes' do
    expect(EditedEntity).to receive(:create).once
    perform_enqueued_jobs { CreateEditedEntityJob.perform_later(entity_version) }
  end

  it 'Relationship verison: creates two Edited Entities' do
    expect(EditedEntity).to receive(:create).twice
    perform_enqueued_jobs { CreateEditedEntityJob.perform_later(relationship_version) }
  end
end
