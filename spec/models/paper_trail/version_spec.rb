# frozen_string_literal: true

require 'rails_helper'

describe PaperTrail::Version do

  describe '#entity_edit?' do
    it 'returns true for entity version' do
      expect(build(:entity_version).entity_edit?).to be true
    end

    it 'returns true for relationship version' do
      expect(build(:relationship_version).entity_edit?).to be true
    end

    it 'returns false for page' do
      expect(build(:page_version).entity_edit?).to be false
    end
  end

  describe 'after create' do
    let(:entity) { create(:entity_person) }
    let(:entity_version) { build(:entity_version, item_id: entity.id) }
    let(:page_version) { build(:page_version) }

    it 'starts edited entity job for entity version' do
      expect(CreateEditedEntityJob).to receive(:perform_later).with(entity_version).once
      entity_version.save!
    end

    it 'skips starting edited entity job for page version' do
      expect(CreateEditedEntityJob).not_to receive(:perform_later)
      page_version.save!
    end
  end
end
