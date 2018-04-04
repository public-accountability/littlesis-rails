require 'rails_helper'

describe ToolsHelper, type: :helper do
  describe '#relationship_select_builder' do
    let(:org) { build(:org) }
    let(:person) { build(:person) }

    before do
      @html_org = helper.relationship_select_builder(org).to_s
      @html_person = helper.relationship_select_builder(person).to_s
    end

    it 'puts family only for person' do
      expect(@html_org).not_to include 'Family'
      expect(@html_person).to include 'Family'
    end

    it 'says "Transaction" not "Trans"' do
      expect(@html_person).not_to include '>Trans</option>'
      expect(@html_person).to include '>Transaction</option>'
    end

    it 'includes position for both' do
      expect(@html_org).to include 'Position'
      expect(@html_person).to include 'Position'
    end

    it 'does not include regular donation (cat #5)' do
      expect(@html_org).not_to include 'value="5"'
      expect(@html_person).not_to include 'value="5"'
    end

    it 'does not include regular membership (cat #3)' do
      expect(@html_org).not_to include 'value="3"'
      expect(@html_person).not_to include 'value="3"'
    end

    it 'includes Donations Received and Given Tags' do
      expect(@html_org).to include 'Donations Received'
      expect(@html_person).to include 'Donations Received'
      expect(@html_org).to include 'Donations Given'
      expect(@html_person).to include 'Donations Given'
    end

    context 'membership' do
      context 'entity is an org' do
        specify do
          expect(@html_org).to include '>Memberships</option>'
          expect(@html_org).to include '>Members</option>'
          expect(@html_org).to include 'value="30"'
          expect(@html_org).to include 'value="31"'
        end
      end

      context 'entity is an person' do
        specify do
          expect(@html_person).to include '>Memberships</option>'
          expect(@html_person).not_to include '>Members</option>'
          expect(@html_person).to include 'value="30"'
          expect(@html_person).not_to include 'value="31"'
        end
      end
    end
  end
end
