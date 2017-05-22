require 'rails_helper'

describe EntitiesHelper do
  describe '#type_select_boxes_person' do
    it 'has 2 columns for person' do
      expect(helper.type_select_boxes_person(build(:person)).scan('col-sm-4').count).to eq 2
    end
  end

  describe '#checkboxes' do
    it 'contains all 7 tier two types' do
      expect(helper.checkboxes(build(:org), ExtensionDefinition.org_types_tier2).reduce(:+).scan('<span class="entity-type-name"').count).to eq 7
    end

    it 'contains all 18 tier 3 types' do
      expect(helper.checkboxes(build(:org), ExtensionDefinition.org_types_tier3).reduce(:+).scan('<span class="entity-type-name"').count).to eq 18
    end

    it 'contains all 9 extension person types' do
      expect(helper.checkboxes(build(:person), ExtensionDefinition.person_types).reduce(:+).scan('<span class="entity-type-name"').count).to eq 9
    end

    it 'contains one checkbox if org has an extension' do
      org = create(:org)
      org.add_extension('Business')
      expect(helper.checkboxes(org, ExtensionDefinition.org_types_tier2).reduce(:+).scan('glyphicon-check').count).to eq 1
      expect(helper.checkboxes(org, ExtensionDefinition.org_types_tier2).reduce(:+).scan('glyphicon-unchecked').count).to eq 6
    end
  end

  describe '#glyph_checkbox' do
    it 'return a checked box if true is passed as first argument' do
      expect(helper.glyph_checkbox(true, 1)).to include 'glyphicon-check'
    end

    it 'returns an unchecked box if first argument is false' do
      expect(helper.glyph_checkbox(false, 1)).to include 'glyphicon-unchecked'
    end

    it 'has data-definition-id' do
      expect(helper.glyph_checkbox(false, 15)).to include 'data-definition-id="15"'
    end
  end
end
