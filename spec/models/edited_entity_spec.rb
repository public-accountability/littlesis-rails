# frozen_string_literal: true

require 'rails_helper'

describe EditedEntity, type: :model do
  let(:entity_id) { Faker::Number.unique.number(8).to_i }
  let(:version_id) { Faker::Number.unique.number(8).to_i }
  let(:user_id) { Faker::Number.unique.number(4).to_i }
  let(:created_at) { Faker::Date.backward(100) }

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

  describe 'unique verison_id/entity_id' do
    before do
      EditedEntity.create!(entity_id: entity_id,
                           version_id: version_id,
                           user_id: user_id,
                           created_at: created_at)
    end

    it 'raises error when encouters duplicate version_id/entity_id combo' do
      expect do
        EditedEntity.create!(entity_id: entity_id,
                             version_id: version_id,
                             user_id: rand(10_000),
                             created_at: Time.current)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'permits creations when version id is different' do
      expect do
        EditedEntity.create!(entity_id: entity_id,
                             version_id: Faker::Number.unique.number(8).to_i,
                             user_id: rand(10_000),
                             created_at: Time.current)
      end.not_to raise_error
    end
  end
end
