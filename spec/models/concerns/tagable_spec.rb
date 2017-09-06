require 'rails_helper'

describe Tagable, :tag_helper do
  seed_tags

  module Assocations
    def has_many(*args)
    end
  end

  class TestTagable
    attr_reader :id
    extend Assocations
    include Tagable
    @@id = 0

    def initialize
      @@id += 1
      @id = @@id
    end

    def tags
    end

    def taggings
    end
  end

  let(:test_tagable) { TestTagable.new }
  let(:all_tags) { Tag.all }

  before(:all) do
    Tagging.skip_callback(:save, :after, :update_tagable_timestamp)
  end

  after(:all) do
    Tagging.set_callback(:save, :after, :update_tagable_timestamp)
  end

  describe "the Tagable interface" do
    let(:entity) { create(:org) }

    it "responds to interface methods" do
      [Entity.new, Relationship.new, List.new].each do |tagable|
        expect(tagable).to respond_to(:tag)
        expect(tagable).to respond_to(:tags)
        expect(tagable).to respond_to(:last_user_id)
      end
    end

    it "implements :tags correctly" do
      entity.tag('oil')

      expect(entity.tags.length).to eq 1
      expect(entity.tags[0]).to be_a Tag
      expect(entity.tags[0].name).to eq 'oil'
    end

    it "implements :taggings correctly" do
      entity.tag('oil')
      expect(entity.taggings.length).to eq 1
      expect(entity.taggings[0]).to be_a Tagging
      expect(entity.taggings[0].tagable_id).to eq entity.id
    end
  end

  describe 'creating a tag' do
    it "creates a new tagging" do
      expect { test_tagable.tag("oil") }.to change { Tagging.count }.by(1)
    end

    it 'only creates one tagging per tag' do
      expect {
        test_tagable.tag("oil")
        test_tagable.tag("oil")
      }.to change { Tagging.count }.by(1)
    end

    it "creates a tagging with correct attributes" do
      test_tagable.tag("oil")
      attrs = Tagging.last.attributes
      expect(attrs['tag_id']).to eq 1
      expect(attrs['tagable_class']).to eq 'TestTagable'
      expect(attrs['tagable_id']).to eq test_tagable.id
    end
  end

  describe 'adding tags' do

    it "can be tagged with an existing tag's id" do
      expect { test_tagable.tag(1) }.to change { Tagging.count }.by(1)
    end

    it "cannot be tagged with a non-existent tag id or name" do
      not_found = ActiveRecord::RecordNotFound
      expect { test_tagable.tag("THIS IS NOT A REAL TAG!!!!") }.to raise_error(not_found)
      expect { test_tagable.tag(1_000_000) }.to raise_error(not_found)
    end
  end

  describe 'removing a tag' do
    it 'removes a tag via active record' do
      mock_taggings = double('taggings')
      expect(mock_taggings).to receive(:find_by_tag_id).with(1).and_return(double(:destroy => nil))
      expect(test_tagable).to receive(:taggings).once.and_return(mock_taggings)
      test_tagable.remove_tag(1)
    end
  end

  describe 'updating tags' do
    let(:preset_tags) { [] }
    before(:each) { expect(test_tagable).to receive(:tags).and_return(preset_tags) }

    context 'in a batch -- with no initial tags' do
      it 'adds tags in a batch with tags as ints' do
        expect { test_tagable.update_tags([1, 2]) }.to change { Tagging.count }.by(2)
      end

      it 'adds tags in a batch with tags as strings' do
        expect { test_tagable.update_tags(['1', '2']) }.to change { Tagging.count }.by(2)
      end

      it 'returns self' do
        expect(test_tagable.update_tags([])).to be_a TestTagable
      end
    end

    context "in a batch -- with pre-existing tags" do
      let(:preset_tags) { Tag.all.limit(2) }

      it 'removes tags in a batch' do
        expect(test_tagable).to receive(:remove_tag).twice
        test_tagable.update_tags([])
      end

      it 'adds and removes tags in a batch' do
        expect(test_tagable).to receive(:remove_tag).once.with(2)
        expect(test_tagable).to receive(:tag).once.with(3)
        test_tagable.update_tags(['1', '3'])
      end
    end
  end

  describe 'formating tags for user editing' do

    let(:owner) { create_really_basic_user }
    let(:non_owner) { create_really_basic_user }

    # we have to use string keys here (unlike everywhere else) b/c of our Tag wanna-be model
    let(:full_access) { { viewable:  true, editable:  true } }
    let(:view_only_access) { { viewable: true, editable: false } }

    before(:each) do
      test_tagable.tag("nyc")
      owner.permissions.add_permission(Tag, { tag_ids: [2]}) # nyc (restricted)
      allow(test_tagable).to receive(:tags).and_return([ Tag.find(1) ])
    end

    def verify_permissions(user, expected_permissions)
      expect(
        test_tagable.tags_for(user)[:byId].values.map{ |t| t['permissions'] }
      ).to eq expected_permissions
    end

    it "returns all tags in map by stringified ids" do
      tags = test_tagable.tags_for(owner)
      expect(test_tagable.tags_for(owner)[:byId].keys).to eq(['1', '2', '3'])
    end

    it "returns current tags as a list of ids" do
      expect(test_tagable.tags_for(owner)[:current]).to eq ['1']
    end

    it "enriches full tag list with permission info" do
      verify_permissions(non_owner, [full_access, view_only_access, full_access])
      verify_permissions(owner, [full_access] * 3)
    end
  end
end
