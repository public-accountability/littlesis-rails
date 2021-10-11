describe EntitiesHelper do
  context 'with a person and an org' do
    let(:person) { build(:person, name: 'Tronald Dump') }
    let(:org) { build(:org, name: 'Malwart') }

    describe 'concretizing URL helpers' do
      it 'generates the correct path for people' do
        expect(helper.concretize_entity_path(person)).to eq "/person/#{person.id}-Tronald_Dump"
      end

      it 'generates the correct path for orgs' do
        expect(helper.concretize_entity_path(org)).to eq "/org/#{org.id}-Malwart"
      end

      it 'generates the correct URL for people' do
        expect(helper.concretize_entity_url(person)).to eq "http://test.host/person/#{person.id}-Tronald_Dump"
      end

      it 'generates the correct edit path' do
        expect(helper.concretize_edit_entity_path(org)).to eq "/org/#{org.id}-Malwart/edit"
      end

      it 'generates the correct history path' do
        expect(helper.concretize_history_entity_path(org)).to eq "/org/#{org.id}-Malwart/history"
      end

      it 'handles other arguments' do
        expect(helper.concretize_political_entity_path(org, format: :json)).to eq "/org/#{org.id}-Malwart/political.json"
      end
    end
  end

  describe 'link_to_all' do
    let(:entity) { build(:org) }

    context 'length of LinksGroup is less than 10' do
      let(:links_group) { LinksGroup.new([], 'keyword', 'heading', 2) }

      it 'returns nil' do
        expect(helper.link_to_all(entity, links_group)).to be nil
      end
    end

    context 'LinksGroup is greater than 10' do
      let(:links_group) { LinksGroup.new([], 'keyword', 'heading', 15) }
      subject { helper.link_to_all(entity, links_group) }

      it { is_expected.to have_css 'div.section_meta', count: 1 }
      it { is_expected.to have_css 'a', text: 'see all' }
      it { is_expected.to include "/org/#{entity.to_param}?relationships=keyword" }
    end
  end

  describe '#type_select_boxes_person' do
    it 'has 2 columns for person' do
      expect(helper.type_select_boxes_person(build(:person)).scan('col-sm-4').count).to eq 2
    end
  end

  describe '#checkboxes' do
    it 'contains all 7 tier two types' do
      expect(helper
               .checkboxes(checked_ids: [], definitions: ExtensionDefinition.org_types_tier2)
               .scan('<span>')
               .count).to eq 7
    end

    it 'contains all 21 tier 3 types' do
      expect(helper
               .checkboxes(checked_ids: [],
                           definitions: ExtensionDefinition.org_types_tier3)
               .scan('<span>')
               .count).to eq 21
    end

    it 'contains all 9 extension person types' do
      expect(helper
               .checkboxes(checked_ids: [],
                           definitions: ExtensionDefinition.person_types)
               .scan('<span>')
               .count).to eq 9
    end

    it 'contains one checkbox if org has an extension' do
      org = create(:entity_org)
      org.add_extension('Business')
      expect(helper.org_boxes_tier2(org).scan('bi-check-square').count).to eq 1
      expect(helper.org_boxes_tier2(org).scan('bi-square').count).to eq 6
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
