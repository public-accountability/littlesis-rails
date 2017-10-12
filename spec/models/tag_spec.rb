require 'rails_helper'

describe Tag do

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

        let(:entities_by_type) do
          {
            'Person' => Array.new(5) { create(:entity_person).add_tag(tag.id) },
            'Org' => Array.new(5) { create(:entity_org).add_tag(tag.id) }
          }
        end

        before do
          relate = ->(x, ys) { ys.each { |y| create(:generic_relationship, entity: x, related: y) } }
          entities_by_type.each do |_, es|
            # relationships: es[4]: 3, es[3] & es[2]: 2, es[1]: 1, es[0]: 0
            relate.call(es[4], es[1, 3])
            relate.call(es[3], [es[2]])
            # es[0] has 6 relationships to random person: won't affect sort, b/c person not tagged
            relate.call(es[0], Array.new(6) { create(:entity_person) })
          end
        end

        # TODO: Fails on travis repeatably but not locally, WHY!?
        xit 'lists entities by type, sorted by relationships to same-tagged entities of any type' do
          tagable_list = tag.tagables_for_homepage(Entity.category_str)
          entities_by_type.each do |type, es|
            id_counts = tagable_list[type].map { |p| [p.id, p.relationship_count] }

            expect(id_counts[0]).to eq [es[4].id, 3]
            expect(id_counts[1, 2].to_set).to eq [[es[3].id, 2], [es[2].id, 2]].to_set
            expect(id_counts[3]).to eq [es[1].id, 1]
            expect(id_counts[4]).to eq [es[0].id, 0]
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
            expect(tag.tagables_for_homepage('lists', 2).size).to eq 1
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
      let(:system_user) { SfGuardUser.find(APP_CONFIG["system_user_id"]).user }
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
        tagables.each { |t| t.add_tag(tag.id, user.sf_guard_user_id) }
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
        let(:tomorrow) { Date.tomorrow }
        let(:relationship) { relationships.first }
        before { relationship.update_column(:updated_at, tomorrow) }

        it 'shows a `tagable_updated` event' do
          expect(tag.recent_edits.first)
            .to eq("tagable"            => relationships.first,
                   "tagable_class"      => "Relationship",
                   "event"              => "tagable_updated",
                   "event_timestamp"    => tomorrow,
                   "editor"             => system_user)
        end
      end
    end
  end

  describe 'Class Methods' do
    before(:each) do
      @oil = build(:oil_tag)
      @nyc = build(:nyc_tag)
      @finance = build(:finance_tag)
      @real_estate = build(:real_estate_tag)
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
      it 'returns a hash lookup table of all tags by name' do
        expect(Tag.lookup).to eq('oil' => @oil,
                                 'nyc' => @nyc,
                                 'finance' => @finance,
                                 'real estate' => @real_estate)
      end
    end
    
  end
end
