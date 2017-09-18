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
      let(:orgs) { Array.new(4) { |n| create(:entity_org, name: "org#{n}") } }

      context "entities" do
        before do
          relate = ->(x, ys) { ys.each { |y| create(:generic_relationship, entity: x, related: y) } }
          orgs.each { |x| x.tag(tag.id) }
          # orgs[3]: 3 relationships, orgs[1] & orgs[2]: 2 relationships, orgs[0]: 1 relationship
          relate.call(orgs[3], orgs[0, 3])
          relate.call(orgs[1], [orgs[2]])

          # orgs[0] has 3 relationships to person, which won't affect sort, b/c person not tagged
          relate.call(orgs[0], Array.new(3) { create(:entity_person) })
        end

        it 'retrieves entities sorted by relationships to similarly-tagged entities' do
          sorted_entities = tag.tagables_for_homepage(Entity.category_str)
          fields = sorted_entities.map { |e| [e.id, e.related_tagged_entities] }

          expect(fields[0]).to eql [orgs[3].id, 3]
          # sorting of 2nd & 3rd elements are indeterminate & interchangable
          expect(Set.new(fields[1, 2])).to eql Set.new([[orgs[1].id, 2], [orgs[2].id, 2]])
          expect(fields[3]).to eql [orgs[0].id, 1]
        end
      end

      context 'all other tagables' do
        %w[lists relationships].each do |tagable_cat|
          it "dispatches to default search method for tagbles: #{tagable_cat}" do
            expect(tag).to receive(:default_tagables_for_homepage).with(tagable_cat, 1).once
            tag.tagables_for_homepage(tagable_cat)
          end
        end
      end

      context "relationships" do
        let(:lists) { [create(:list), create(:list)] }
        before do
          lists.each { |l| l.tag(tag.id) }
          lists[0].update_column(:updated_at, 1.day.ago)
        end

        it "retrieves lists sorted by last date modified" do
          sorted_lists = tag.tagables_for_homepage(List.category_str)
          expect(sorted_lists).to eq lists.reverse
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
