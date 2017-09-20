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
      let(:entities_by_type) do
        {
          'Person' => Array.new(5) { create(:entity_person).tag(tag.id) },
          'Org' => Array.new(5) { create(:entity_org).tag(tag.id) }
        }
      end

      context "entities" do
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

        it 'lists entities by type, sorted by relationships to same-tagged entities of any type' do
          tagable_list = tag.tagables_for_homepage(Entity.category_str)
          entities_by_type.each do |type, es|
            id_counts = tagable_list[type].map { |p| [p.id, p.num_related] }

            expect(id_counts[0]).to eq [es[4].id, 3]
            expect(id_counts[1, 2].to_set).to eq [[es[3].id, 2], [es[2].id, 2]].to_set
            expect(id_counts[3]).to eq [es[1].id, 1]
            expect(id_counts[4]).to eq [es[0].id, 0]
          end
        end
      end

      context 'all other tagables' do
        let(:lists) { Array.new(2) { create(:list)} }
        let(:relationships) do
          Array.new(2) do
            create(:generic_relationship,
                   entity: create(:entity_person),
                   related: create(:entity_org))
          end
        end
        categories = Tagable.categories.reject { |c| c == Entity.category_sym }

        categories.each do |tagable_cat|
          before do
            send(tagable_cat).each{ |t| t.tag(tag.id)}
            send(tagable_cat).first.update_column(:updated_at, 1.day.ago)
          end
          context tagable_cat do
            it "sorts #{tagable_cat} by date" do
              expect(tag.tagables_for_homepage(tagable_cat).to_a).to eq send(tagable_cat).reverse
            end
          end
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
