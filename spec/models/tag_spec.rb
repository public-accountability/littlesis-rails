describe Tag, :pagination_helper do
  let(:tags) { Array.new(3) { create(:tag) } }

  it { should have_db_column(:restricted) }
  it { should have_db_column(:name) }
  it { should have_db_column(:description) }
  it { should have_many(:taggings) }

  describe 'validations' do
    let(:tag) { build(:tag) }
    subject { tag }

    describe 'validations' do
      subject { Tag.new(name: 'fake tag name', description: 'all about fake tags') }

      it { should validate_uniqueness_of(:name) }
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:description) }
    end

    describe "associations" do
      Tagable.classes.each do |klass|
        it { should have_many(klass.category_sym) }
      end
    end

    describe 'strip whitespace' do
      it 'remove whitepspace before creating' do
        tag = create(:tag, name: ' spacy-tag-name ')
        expect(Tag.find(tag.id).name).to eql 'spacy-tag-name'
      end
    end
  end

  describe '#entities_by_relationship_count' do
    let(:tag) { create(:tag) }
    let!(:people) do
      Array.new(4) { |n| create(:entity_person, name: "person#{n} lastname").add_tag(tag.id) }
    end
    let!(:orgs) { Array.new(2) { create(:entity_org).add_tag(tag.id) } }
    before do
      people.slice(0, 3).each do |person|
        create(:generic_relationship, entity: people[3], related: person)
      end
      create(:generic_relationship, entity: people[1], related: people[2])
      2.times { create(:generic_relationship, entity: people[1], related: create(:entity_person)) }
    end

    it 'returns 4 People, correctly sorted' do
      expect(tag.send(:entities_by_relationship_count, 'Person').length).to eql 4
      expect(tag.send(:entities_by_relationship_count, 'Person').first).to eq people[3].reload
      expect(tag.send(:entities_by_relationship_count, 'Person').first.relationship_count).to eq 3
      expect(tag.send(:entities_by_relationship_count, 'Person').last.relationship_count).to eq 1
    end

    it 'returns 2 Orgs' do
      expect(tag.send(:entities_by_relationship_count, 'Org').length).to eql 2
    end
  end

  describe "Instance methods" do
    let(:tag) { create(:tag) }
    let(:restricted_tag) { build(:tag, restricted: true) }

    it 'can determine if a tag is restricted' do
      expect(tag.restricted?).to be false
      expect(restricted_tag.restricted?).to be true
    end

    describe "querying tagables for tag homepage" do
      context "entities" do
        let!(:people) do
          Array.new(4) { |n| create(:entity_person, name: "person#{n} lastname").add_tag(tag.id) }
        end
        let!(:orgs) { Array.new(4) { |n| create(:entity_org, name: "org#{n}").add_tag(tag.id) } }
        let!(:setup_people_relationships) do
          # creates 4 relationsips: with the following totals:
          # people[0] = 1
          # people[1] = 2
          # people[2] = 2
          # people[3] = 3
          people.slice(0, 3).each do |person|
            create(:generic_relationship, entity: people[3], related: person)
          end
          create(:generic_relationship, entity: people[1], related: people[2])
        end

        let(:person_with_the_most_relationships) { people.last.reload }
        let(:person_with_the_least_relationships) { people.first.reload }

        let!(:setup_org_relationships) do
          # creates 4 relationsips with the following totals:
          # with the following totals:
          # orgs[0] = 1
          # orgs[1] = 2
          # orgs[2] = 2
          # orgs[3] = 3
          orgs.slice(0, 3).each do |org|
            create(:generic_relationship, entity: orgs[3], related: org)
          end
          create(:generic_relationship, entity: orgs[1], related: orgs[2])
        end

        let(:org_with_the_most_relationships) { orgs.last.reload }
        let(:org_with_the_least_relationships) { orgs.first.reload }

        context 'sorting' do
          subject do
            tag.tagables_for_homepage('entities')
          end
          it 'finds people sorted by count' do
            expect(subject['Person'].length).to eql 4
            expect(subject['Person'].first).to eql person_with_the_most_relationships
            expect(subject['Person'].last).to eql person_with_the_least_relationships
          end

          it 'finds org sorted by count' do
            expect(subject['Org'].length).to eql 4
            expect(subject['Org'].first).to eql org_with_the_most_relationships
            expect(subject['Org'].last).to eql org_with_the_least_relationships
          end
        end

        context 'pagination' do
          stub_page_limit Tag, limit: 3

          context 'when asking for the default settings: page 1' do
            subject { tag.tagables_for_homepage 'entities' }

            it 'contains 3 people and 3 orgs' do
              expect(subject['Person'].length).to eql 3
              expect(subject['Org'].length).to eql 3
            end
          end

          context 'asking for page 2 for both people and orgs' do
            subject { tag.tagables_for_homepage 'entities', person_page: 2, org_page: 2 }
            it 'contains 1 people and 1 org' do
              expect(subject['Person'].length).to eql 1
              expect(subject['Org'].length).to eql 1
            end
          end

          context 'asking for page 1 for people and page 2 for orgs' do
            subject { tag.tagables_for_homepage 'entities', person_page: 1, org_page: 2 }
            it 'contains 3 people and 1 org' do
              expect(subject['Person'].length).to eql 3
              expect(subject['Org'].length).to eql 1
            end
          end
        end
      end

      context "lists" do

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
            expect(tagables.map(&:entity_count)).to eq [1,0]
          end
        end

        describe "pagination" do

          let(:page_limit){ Tag::PER_PAGE }
          let(:lists) { Array.new(page_limit + 1) { create(:list).add_tag(tag.id) } }
          before { lists }

          it "shows records corresponding to a given page" do
            expect(tag.tagables_for_homepage('lists', page: 2).size).to eq 1
          end

          it "limits the number of records shown on a given page" do
            expect(tag.tagables_for_homepage('lists').size).to eq 20
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
              .to eq("tagable"         => tagables[idx],
                     "tagable_class"   => tagables[idx].class.name,
                     "event"           => "tag_added",
                     "event_timestamp" => tagables[idx].taggings.last.created_at,
                     "editor"          => user)
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
    before(:each) do
      @oil = build(:oil_tag, :with_tag_id)
      @nyc = build(:nyc_tag, :with_tag_id)
      @finance = build(:finance_tag, :with_tag_id)
      @real_estate = build(:real_estate_tag, :with_tag_id)
      Tag.instance_variable_set(:@lookup, nil)
      allow(Tag).to receive(:all).and_return([@oil, @nyc, @finance, @real_estate])
    end

    describe('#parse_update_actions') do
      it 'partitions tag ids from client into hash of update actions to be taken' do
        client_ids = [1, 2, 3].to_set
        server_ids = [2, 3, 4].to_set
        expect(Tag.parse_update_actions(client_ids, server_ids))
          .to eql(
                add: [1].to_set,
                remove: [4].to_set,
                ignore: [2, 3].to_set
              )
      end
    end

    describe '#search_by_name' do
      it 'finds tag by if search includes exact name' do
        expect(Tag.search_by_name('oil')).to eql @oil
        expect(Tag.search_by_name('nyc')).to eql @nyc
      end

      it 'finds tag regardless of capitalization' do
        expect(Tag.search_by_name('OIL')).to eql @oil
        expect(Tag.search_by_name('nYc')).to eql @nyc
      end

      it 'return nil if there is no tag' do
        expect(Tag.search_by_name('NOTATAG')).to be nil
      end
    end

    describe '#get' do
      it 'finds tag by if search includes exact name' do
        expect(Tag.get('oil')).to eql @oil
      end

      it 'finds tag by integer' do
        expect(Tag.get(@oil.id)).to eql @oil
      end

      it 'finds tag by string integer' do
        expect(Tag.get(@oil.id.to_s)).to eql @oil
      end

      it 'return nil if there is no tag' do
        expect(Tag.get('foo')).to be nil
      end
    end

    describe '#search_by_names' do
      let(:phrase) { '' }
      subject { Tag.search_by_names(phrase) }

      it { is_expected.to be_a Array }

      context 'phrase contains one tag' do
        let(:phrase) { "oil barons" }
        it { should eql [@oil] }
      end

      context 'phrase contains two tag' do
        let(:phrase) { "oil barons who like finance" }
        it { should eql [@oil, @finance] }
      end

      context 'phrase contains a repeated tag name' do
        let(:phrase) { "nyc nyc" }
        it { should eql [@nyc] }
      end

      context 'phrase contains real estate' do
        let(:phrase) { "my rent is too high. DAMN REAL ESTATE INDUSTRY" }
        it { should eql [@real_estate] }
      end

      context 'phrase is unrelated to tags' do
        let(:phrase) { "nothing to see here" }
        it { should eql [] }
      end
    end

    describe 'lookup' do
      it 'returns a hash lookup table of all tags by name and id' do
        expect(Tag.lookup).to eq(@oil.id => @oil,
                                 'oil' => @oil,
                                 @nyc.id => @nyc,
                                 'nyc' => @nyc,
                                 @finance.id => @finance,
                                 'finance' => @finance,
                                 @real_estate.id => @real_estate,
                                 'real estate' => @real_estate,
                                 'real-estate' => @real_estate)
      end
    end
  end # end class method
end
