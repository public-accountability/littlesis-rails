require 'rails_helper'

describe EntitiesHelper do
  describe '#type_select_boxes' do
    it 'has 5 columns for orgs' do
      expect(helper.type_select_boxes(build(:org)).scan('col-sm-4').count).to eq 3
    end

    it 'has 2 columns for orgs' do
      expect(helper.type_select_boxes(build(:person)).scan('col-sm-4').count).to eq 2
    end
  end

  describe '#checkboxes' do
    it 'calls "ExtensionDefintion.org_types" if provided an org' do
      expect(ExtensionDefinition).to receive(:org_types).once.and_return([])
      helper.checkboxes(build(:org))
    end

    it 'calls "ExtensionDefintion.person_types" if provided an person' do
      expect(ExtensionDefinition).to receive(:person_types).once.and_return([])
      helper.checkboxes(build(:person))
    end

    it 'contains all 25 extension org types' do
      expect(helper.checkboxes(build(:org)).reduce(:+).scan('<span class="entity-type-name"').count).to eq 25
    end

    it 'contains all 9 extension person types' do
      expect(helper.checkboxes(build(:person)).reduce(:+).scan('<span class="entity-type-name"').count).to eq 9
    end

    it 'contains one checkbox if org has an extension' do
      org = create(:org)
      org.add_extension('Business')
      expect(helper.checkboxes(org).reduce(:+).scan('glyphicon-check').count).to eq 1
      expect(helper.checkboxes(org).reduce(:+).scan('glyphicon-unchecked').count).to eq 24
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

  describe 'Sidebar helpers' do
    # describe '#sidebar_reference_count' do
    #   it 'generates correct text' do
    #     expect(helper.sidebar_reference_count(22)).to include "Number of references"
    #     expect(helper.sidebar_reference_count(22)).to include "22"
    #     expect(helper.sidebar_reference_count(22)).to include "<span"
    #   end
    # end

    describe '#sidebar references' do
      it 'creates 10 ul tags' do
        refs = Array.new(10).collect { build(:entity_ref) }
        expect(helper.sidebar_references(refs).scan(/<li>/).count).to eq 10
      end
    end

    describe '#sidebar_reference' do
      before { @ref = build(:entity_ref) }

      it 'has link and li tag' do
        expect(helper.sidebar_reference(@ref)).to have_selector(:css, "a li", count: 1)
      end

      it 'includes entity url' do
        expect(helper.sidebar_reference(@ref)).to include 'littlesis.org'
      end
    end
  end # end Sidebar helpers
end
