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

    it 'contains all 20 tier 3 types' do
      expect(helper.checkboxes(build(:org), ExtensionDefinition.org_types_tier3)
               .reduce(:+).scan('<span class="entity-type-name"').count).to eq 20
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

  describe '#show_add_bulk_button' do
    it 'returns true for admin user' do
      expect(helper.show_add_bulk_button(create_admin_user)).to be true
    end

    it 'returns true for bulker' do
      expect(helper.show_add_bulk_button(create_bulk_user)).to be true
    end

    it 'returns true for users with accounts older than 2 weeks and who have signed in more than 2 times' do
      user = create_basic_user
      expect(user).to receive(:created_at).and_return(1.month.ago)
      expect(user).to receive(:sign_in_count).and_return(3)
      expect(helper.show_add_bulk_button(user)).to be true
    end

    it 'returns false for users with accounts newer than 2 weeks' do
      user = create_basic_user
      expect(user).to receive(:created_at).and_return(1.week.ago)
      expect(helper.show_add_bulk_button(user)).to be false
    end

    it 'returns false for users wwho have signed in less than 3 times' do
      user = create_basic_user
      expect(user).to receive(:created_at).and_return(1.month.ago)
      expect(user).to receive(:sign_in_count).and_return(2)
      expect(helper.show_add_bulk_button(user)).to be false
    end
  end
end
