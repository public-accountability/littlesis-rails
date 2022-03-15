describe Tagable, type: :model do
  let(:test_tagable) { create(:entity_org) }
  let(:tags) { Array.new(3) { create(:tag) } }
  let(:tag_name) { tags.first.name }
  let(:tag_id) { tags.first.id }
  let(:entity) { create(:entity_org) }

  describe "the Tagable interface" do
    before { entity.add_tag(tag_id) }

    it "responds to interface methods" do
      Tagable.classes.each do |tagable_class|
        tagable = tagable_class.new
        expect(tagable).to respond_to(:add_tag)
        expect(tagable).to respond_to(:remove_tag)
        expect(tagable).to respond_to(:update_tags)
        expect(tagable).to respond_to(:tags)
        expect(tagable).to respond_to(:taggings)
        expect(tagable).to respond_to(:tags_for)
        expect(tagable).to respond_to(:description)
        expect(tagable).to respond_to(:last_user_id)
      end
    end

    it "implements :tags correctly" do
      expect(entity.tags.length).to eq 1
      expect(entity.tags[0].name).to eq tag_name
    end

    it "implements :taggings correctly" do
      expect(entity.taggings.length).to eq 1
      expect(entity.taggings[0].tagable_id).to eq entity.id
    end
  end

  describe "class methods" do

    describe"on Tagable module itself" do

      it "enumerates all Tagable classes" do
        expect(Tagable.classes).to eq([Entity, List, Relationship])
      end

      it "enumerates all Tagable categories" do
        expect(Tagable.categories).to eq(%i[entities lists relationships])
      end

      it "generates a class name from a category symbol" do
        Tagable.categories.zip(Tagable.classes).each do |category, klass|
          expect(Tagable.class_of(category)).to eq klass
        end
      end
    end

    describe "on tagable instances" do

      it "does not expose Tagable class methods" do
        expect(Entity).not_to respond_to(:classes)
      end

      it "provides pluralized symbol for tagable category" do
        expect(Entity.category_sym).to eq(:entities)
        expect(List.category_sym).to eq(:lists)
        expect(Relationship.category_sym).to eq(:relationships)
      end

      it "provides pluralized string for tagable category" do
        expect(Entity.category_str).to eq('entities')
        expect(List.category_str).to eq('lists')
        expect(Relationship.category_str).to eq('relationships')
      end
    end
  end

  describe 'creating a tag' do
    let(:user) { create(:user) }
    let(:system_user) { User.system_user }
    let(:test_tagable) { create(:entity_org) }

    it "creates a new tagging" do
      expect { test_tagable.add_tag(tag_id) }.to change { Tagging.count }.by(1)
    end

    it "tracks user who created tag" do
      test_tagable.add_tag(tag_id, user.id)
      expect(Tagging.last.last_user_id).to eql user.id
      expect(Tagging.last.last_user).to eql user
    end

    it "provides sysem user as default user" do
      test_tagable.add_tag(tag_id)
      expect(Tagging.last.last_user_id).to eq User.system_user_id
      expect(Tagging.last.last_user).to eq system_user
    end

    it 'only creates one tagging per tag' do
      expect {
        test_tagable.add_tag(tag_id)
        test_tagable.add_tag(tag_id)
      }.to change { Tagging.count }.by(1)
    end

    it 'only allows one user per tagging' do
      test_tagable.add_tag(tag_id, 1)
      test_tagable.add_tag(tag_id, 2)
      expect(Tagging.last.last_user_id).to eq 1
    end

    it "creates a tagging with correct attributes" do
      test_tagable.add_tag(tag_id)

      attrs = Tagging.last.attributes
      expect(attrs['tag_id']).to eq tag_id
      expect(attrs['tagable_class']).to eq 'Entity'
      expect(attrs['tagable_id']).to eq test_tagable.id
    end
  end

  describe 'adding tags' do
    let(:test_tagable) { create(:entity_org) }

    it "can be tagged with an existing tag's id" do
      expect { test_tagable.add_tag(tag_id) }.to change { Tagging.count }.by(1)
    end

    it "can be tagged with an existing tag's name" do
      expect { test_tagable.add_tag(tag_name) }.to change { Tagging.count }.by(1)
    end

    it "cannot be tagged with a non-existent tag id or name" do
      not_found = ActiveRecord::RecordNotFound
      expect { test_tagable.add_tag("THIS IS NOT A REAL TAG!!!!") }.to raise_error(not_found)
      expect { test_tagable.add_tag(1_000_000) }.to raise_error(not_found)
    end
  end

  describe "adding tags without running tagging's callbacks" do
    it 'skips Tagging callback and then re-enables it' do
      tagable = test_tagable
      expect(Tagging).to receive(:skip_callback).with(:save, :after, :update_tagable_timestamp).once
      expect(Tagging).to receive(:set_callback).with(:save, :after, :update_tagable_timestamp).once
      expect(tagable).to receive(:add_tag).with('tagname', User.system_user_id)
      tagable.add_tag_without_callbacks('tagname')
    end

    it 're-enables callbacks even if the tag raises an error' do
      tagable = test_tagable
      expect(Tagging).to receive(:skip_callback).with(:save, :after, :update_tagable_timestamp).once
      expect(Tagging).to receive(:set_callback).with(:save, :after, :update_tagable_timestamp).once
      expect(tagable).to receive(:add_tag).with('tagname', User.system_user_id).and_raise(ActiveRecord::RecordNotFound)
      expect { tagable.add_tag_without_callbacks('tagname') }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'removing a tag' do
    it 'removes a tag via active record' do
      mock_taggings = double('taggings')
      expect(mock_taggings).to receive(:find_by_tag_id)
                                .with(tag_id)
                                .and_return(double(:destroy => nil))
      expect(test_tagable).to receive(:taggings)
                               .once.and_return(mock_taggings)
      test_tagable.remove_tag(tags.first.id)
    end
  end

  describe 'updating tags' do
    let(:preset_tags) { [] }
    let(:tag_ids) { tags[0..1].map(&:id) }
    before(:each) { expect(test_tagable).to receive(:tags).and_return(preset_tags) }

    context 'in a batch -- with no initial tags' do
      it 'adds tags in a batch with tags as ints' do
        expect { test_tagable.update_tags(tag_ids) }.to change { Tagging.count }.by(2)
      end

      it 'adds tags in a batch with tags as strings' do
        expect { test_tagable.update_tags(tag_ids.map(&:to_s)) }.to change { Tagging.count }.by(2)
      end

      it 'returns self' do
        expect(test_tagable.update_tags([])).to be_a Entity
      end
    end

    context "in a batch -- with pre-existing tags" do
      #let(:preset_tags) { Tag.all.limit(2) }
      let(:preset_tags) { tags[0..1] }

      it 'removes tags in a batch' do
        expect(test_tagable).to receive(:remove_tag).twice
        test_tagable.update_tags([])
      end

      it 'adds and removes tags in a batch' do
        expect(test_tagable).to receive(:remove_tag).once.with(tags[1].id)
        expect(test_tagable).to receive(:add_tag).once.with(tags[2].id)
        test_tagable.update_tags([tags[0].id, tags[2].id])
      end
    end
  end

  describe 'formating tags for user editing' do
    let(:user) { create_basic_user }
    let(:restricted_tag) { tags.last.tap { |t| t.update(restricted: true) } }

    let(:full_access) { { viewable: true, editable: true }.with_indifferent_access }
    let(:view_only_access) { { viewable: true, editable: false }.with_indifferent_access }

    before do
      test_tagable.add_tag(restricted_tag.id)
    end

    it "returns all tags in map by stringified ids" do
      expect(test_tagable.tags_for(user)[:byId].keys.to_set).to eq(tags.map(&:id).map(&:to_s).to_set)
    end

    it "returns current tags as a list of ids" do
      expect(test_tagable.tags_for(user)[:current]).to eq [restricted_tag.id.to_s]
    end

    it "enriches full tag list with permission info" do
      expect(
        test_tagable.tags_for(user)[:byId].values.map { |t| t['permissions'] }
      ).to eq ([full_access] * 2) + [view_only_access]
    end
  end
end
