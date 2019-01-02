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

end
