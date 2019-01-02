require 'rails_helper'

describe CreateEditedEntityJob, type: :job do
  include ActiveJob::TestHelper

  let(:attributes) do
    { entity_id: rand(10_000),
      version_id: rand(10_000),
      user_id: rand(10_000),
      created_at: Time.current }
  end

  it 'calls EditedEntity.create! with correct attributes' do
    expect(EditedEntity).to receive(:create!).with(attributes).once
    perform_enqueued_jobs { EditedEntity.create!(attributes) }
  end
end
