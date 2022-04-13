describe Tag, :pagination_helper do
  let(:tags) { Array.new(3) { create(:tag) } }

  it { is_expected.to have_db_column(:restricted) }
  it { is_expected.to have_db_column(:name) }
  it { is_expected.to have_db_column(:description) }
  it { is_expected.to have_many(:taggings) }

  describe 'validations' do
    let(:tag) { build(:tag) }
    subject { tag }

    describe 'validations' do
      subject { Tag.new(name: 'fake tag name', description: 'all about fake tags') }

      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:description) }

      it 'validates uniqueness of name' do
        Tag.create!(name: 'real-estate', description: 'test')
        expect { Tag.create!(name: 'real estate', description: 'test') }.to raise_error(ActiveRecord::RecordInvalid)
        expect { Tag.create!(name: ' real-estate ', description: 'test') }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "associations" do
      Tagable.classes.each do |klass|
        it { is_expected.to have_many(klass.category_sym) }
      end
    end

    describe 'strip whitespace' do
      it 'remove whitepspace before creating' do
        tag = create(:tag, name: ' spacy-tag-name ')
        expect(Tag.find(tag.id).name).to eql 'spacy-tag-name'
      end
    end
  end

  describe 'tag permisions' do
    it 'open tags can be viewed and edited by any editor' do
      tag = build(:tag)
      editor = build(:user, role: 'editor')
      expect(tag.permissions_for(editor)).to eq({ 'viewable' => true, 'editable' => true })
    end

    it 'closed tag can be viewed by any logged in user but only edited by its owner(s) or an admin' do
      tag = build(:tag, restricted: true)
      editor = build(:user, role: 'editor')
      admin = build(:user, role: 'admin')
      expect(tag.permissions_for(editor)).to eq({ 'viewable' => true, 'editable' => false })
      expect(tag.permissions_for(admin)).to eq({ 'viewable' => true, 'editable' => true })
    end
  end


  # describe '#entities_by_relationship_count' do
  #   let(:tag) { create(:tag) }

  #   let(:people) do
  #     Array.new(4) { |n| create(:entity_person, name: "person#{n} lastname").add_tag(tag.id) }
  #   end

  #   let(:orgs) { Array.new(2) { create(:entity_org).add_tag(tag.id) } }

  #   before do
  #     people.slice(0, 3).each do |person|
  #       create(:generic_relationship, entity: people[3], related: person)
  #     end

  #     create(:generic_relationship, entity: people[1], related: people[2])
  #     2.times { create(:generic_relationship, entity: people[1], related: create(:entity_person)) }
  #   end

  #   it 'returns 4 People, correctly sorted' do
  #     expect(tag.send(:entities_by_relationship_count, 'Person').length).to eq 4
  #     expect(tag.send(:entities_by_relationship_count, 'Person').first).to eq people[3].reload
  #     expect(tag.send(:entities_by_relationship_count, 'Person').first.relationship_count).to eq 3
  #     expect(tag.send(:entities_by_relationship_count, 'Person').last.relationship_count).to eq 1
  #   end

  #   it 'returns 2 Orgs' do
  #     expect(tag.send(:entities_by_relationship_count, 'Org').length).to eq 2
  #   end
  # end

  describe "Instance methods" do
    let(:tag) { create(:tag, name: 'tagname') }
    let(:restricted_tag) { build(:tag, restricted: true) }

    it 'can determine if a tag is restricted' do
      expect(tag.restricted?).to be false
      expect(restricted_tag.restricted?).to be true
    end

    describe "querying tagables for tag homepage" do
      describe "entities" do
        let(:people_list) do
          Array.new(4) { |n| create(:entity_person, name: "person#{n} lastname").add_tag(tag.id) }
        end

        let(:orgs_list) do
          Array.new(4) { |n| create(:entity_org, name: "org#{n} lastname").add_tag(tag.id) }
        end

        before do
          people_list
          orgs_list
          # creates 4 relationsips: with the following totals:
          # people[0] = 1
          # people[1] = 2
          # people[2] = 2
          # people[3] = 3
          create(:generic_relationship, entity: people_list[3], related: people_list[0])
          create(:generic_relationship, entity: people_list[3], related: people_list[1])
          create(:generic_relationship, entity: people_list[3], related: people_list[2])
          create(:generic_relationship, entity: people_list[1], related: people_list[2])
          # creates 4 relationsips with the following totals:
          # with the following totals:
          # orgs[0] = 1
          # orgs[1] = 2
          # orgs[2] = 2
          # orgs[3] = 3
          create(:generic_relationship, entity: orgs_list[3], related: orgs_list[0])
          create(:generic_relationship, entity: orgs_list[3], related: orgs_list[1])
          create(:generic_relationship, entity: orgs_list[3], related: orgs_list[2])
          create(:generic_relationship, entity: orgs_list[1], related: orgs_list[2])
        end

        let(:person_with_the_most_relationships) { people_list.last.reload }
        let(:person_with_the_least_relationships) { people_list.first.reload }
        let(:org_with_the_most_relationships) { orgs_list.last.reload }
        let(:org_with_the_least_relationships) { orgs_list.first.reload }

        describe 'sorting' do
          let(:tagables) do
            tag.tagables_for_homepage('entities')

          end

          it 'finds people sorted by count' do
            expect(tagables['Person'].length).to eq 4
            expect(tagables['Person'].first).to eq person_with_the_most_relationships
            expect(tagables['Person'].last).to eq person_with_the_least_relationships
          end

          it 'finds org sorted by count' do
            expect(tagables['Org'].length).to eq 4
            expect(tagables['Org'].first).to eq org_with_the_most_relationships
            expect(tagables['Org'].last).to eq org_with_the_least_relationships
          end
        end

        describe 'pagination' do
          stub_page_limit Tag, limit: 3

          describe 'asking for the default settings: page 1' do
            let(:tagables) { tag.tagables_for_homepage('entities') }

            it 'contains 3 people and 3 orgs' do
              expect(tagables['Person'].length).to eq 3
              expect(tagables['Org'].length).to eq 3
            end
          end

          describe 'asking for page 2 for both people and orgs' do
            let(:tagables) { tag.tagables_for_homepage 'entities', person_page: 2, org_page: 2 }

            it 'contains 1 people and 1 org' do
              expect(tagables['Person'].length).to eq 1
              expect(tagables['Org'].length).to eq 1
            end
          end

          describe 'asking for page 1 for people and page 2 for orgs' do
            let(:tagables) { tag.tagables_for_homepage 'entities', person_page: 1, org_page: 2 }

            it 'contains 3 people and 1 org' do
              expect(tagables['Person'].length).to eq 3
              expect(tagables['Org'].length).to eq 1
            end
          end
        end
      end

      describe "lists" do
        stub_page_limit Tag, limit: 3

        describe "sorting" do
          let(:lists) { Array.new(2) { create(:list).add_tag(tag.id) } }
          let(:tagables) { tag.tagables_for_homepage('lists') }

          before do
            create(:list_entity, list_id: lists.second.id, entity_id: create(:entity_org).id)
          end

          it "lists tagged lists sorted by number of list members" do
            expect(tagables.to_a).to eq lists.reverse
          end

          it "appends an `entities_count` field to List models" do
            expect(tagables.map(&:entity_count)).to eq [1, 0]
          end
        end

        describe "pagination" do
          let!(:lists) { Array.new(3 + 1) { create(:list).add_tag(tag.id) } }

          it "shows records corresponding to a given page" do
            expect(tag.tagables_for_homepage('lists', page: 2).size).to eq 1
          end

          it "limits the number of records shown on a given page" do
            expect(tag.tagables_for_homepage('lists').size).to eq 3
          end
        end
      end

      context "relationships" do
        let(:relationships) do
          Array.new(2) do
            create(
              :generic_relationship,
              entity: create(:entity_person),
              related: create(:entity_org)
            ).add_tag(tag.id)
          end
        end

        before { relationships.first.update_column(:updated_at, 1.day.ago) }

        it "lists tagged relationships sorted in descending order of last edit" do
          expect(tag.tagables_for_homepage('relationships').to_a)
            .to eq relationships.reverse
        end
      end
    end

    describe 'recent edits' do
      let(:user) { create_basic_user }
      let(:system_user) { User.system_user }
      let(:tag) { create(:tag) }

      let(:entities) { Array.new(2) { create(:entity_org) } }
      let(:lists) { Array.new(2) { create(:list) } }
      let(:untagged_person) { create(:entity_person) }
      let(:untagged_org) { create(:entity_org) }
      let(:relationships) do
        Array.new(2) do
          create(:generic_relationship, entity: untagged_person, related: untagged_org)
        end
      end
      let(:tagables){ entities + relationships + lists }

      before do
        tagables.each { |t| t.add_tag(tag.id, user.id) }
        # offset tagging updated_at timestamps to yield
        # reverse chronological ordering equivalent to tagable ordering
        tagables.reverse.each_with_index do |t, i|
          t.taggings.first.update_column(:created_at, Time.now + i.seconds)
        end
      end

      describe 'listing `tag_added` events' do
        it 'shows all `tag_added` events' do
          tag.recent_edits.each_with_index do |edit, idx|
            expect(edit)
              .to eq('tagable' => tagables[idx],
                     'tagable_class' => tagables[idx].class.name,
                     'event' => 'tag_added',
                     'event_timestamp' => tagables[idx].taggings.last.created_at,
                     'editor' => user)
          end
        end
      end

      describe 'listing `tagable_updated` events' do
        let(:new_time) { (Time.current + 10.days) }
        let(:relationship) { relationships.first }

        before do
          relationship.update_column(:updated_at, new_time)
        end

        it 'shows a `tagable_updated` event' do
          update_event = tag.recent_edits.first
          expect(update_event['tagable']).to eq relationships.first
          expect(update_event['tagable_class']).to eq "Relationship"
          expect(update_event['event']).to eq "tagable_updated"
          expect(update_event['editor'].id).to eq 1
          expect(update_event['event_timestamp'].round).to eq new_time.round
        end
      end
    end
  end

  describe 'Class Methods' do
    let(:oil_tag) { create(:oil_tag) }
    let(:nyc_tag) { create(:nyc_tag) }
    let(:finance_tag) { create(:finance_tag) }
    let(:real_estate_tag) { create(:real_estate_tag) }

    before do
      oil_tag; nyc_tag; finance_tag; real_estate_tag;
    end

    describe('#parse_update_actions') do
      it 'partitions tag ids from client into hash of update actions to be taken' do
        client_ids = [1, 2, 3].to_set
        server_ids = [2, 3, 4].to_set
        expect(Tag.parse_update_actions(client_ids, server_ids))
          .to eql(add: [1].to_set, remove: [4].to_set, ignore: [2, 3].to_set)
      end
    end

    describe '#find_by_name' do
      it 'finds tag by if search includes exact name' do
        expect(Tag.find_by_name('oil')).to eq oil_tag
        expect(Tag.find_by_name('nyc')).to eq nyc_tag
      end

      it 'finds tag regardless of capitalization' do
        expect(Tag.find_by_name('OIL')).to eq oil_tag
        expect(Tag.find_by_name('nYc')).to eq nyc_tag
      end

      it 'finds tag when written with spaces' do
        expect(Tag.find_by_name('real estate')).to eq real_estate_tag
      end

      it 'return nil if there is no tag' do
        expect(Tag.find_by_name('NOTATAG')).to be nil
      end
    end

    describe '#fuzzy_search' do
      specify do
        expect(Tag.fuzzy_search('')).to be_a Array
      end

      specify 'phrase contains one tag' do
        expect(Tag.fuzzy_search("oil barons")).to eq [oil_tag]
      end

      specify 'phrase contains two tag' do
        expect(Tag.fuzzy_search("oil barons who like finance")).to eq [oil_tag, finance_tag]
      end

      specify 'phrase contains a repeated tag name' do
        expect(Tag.fuzzy_search("nyc nyc")).to eq [nyc_tag]
      end

      specify 'phrase contains real estate' do
        expect(Tag.fuzzy_search("my rent is too high. DAMN REAL ESTATE INDUSTRY")).to eq [real_estate_tag]
      end

      specify 'phrase is unrelated to tags' do
        expect(Tag.fuzzy_search("nothing to see here")).to eq []
      end
    end
  end # end class method
end
