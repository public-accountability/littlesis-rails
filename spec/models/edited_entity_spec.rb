# frozen_string_literal: true

require 'rails_helper'

describe EditedEntity, type: :model do
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:version_id).of_type(:integer) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to belong_to(:version) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:entity_id) }
  it { is_expected.to validate_presence_of(:version_id) }
  it { is_expected.to validate_presence_of(:created_at) }
  it { is_expected.not_to validate_presence_of(:user_id) }
end
