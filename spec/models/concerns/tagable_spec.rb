require 'rails_helper'

describe Tagable do

  class TestTagable
    attr_reader :id
    include Tagable
    @@id = 0

    def initialize
      @@id += 1
      @id = @@id
    end
  end

  let(:test_tagable) { TestTagable.new }
  let(:other_tagable) { TestTagable.new }

  describe 'creating a tag' do
    it "#tag crates a new tagging" do
      expect { test_tagable.tag("oil") }.to change { Tagging.count }.by(1)
    end

    it "returns Tagging with correct attributes" do
      test_tagable.tag("oil")
      attrs = Tagging.last.attributes
      expect(attrs['tag_id']).to eq 1
      expect(attrs['tagable_class']).to eq 'TestTagable'
      expect(attrs['tagable_id']).to eq test_tagable.id
    end
  end

  it "retrieves tags applied to it" do
    test_tagable.tag("oil")
    expect(test_tagable.tags.to_a)
      .to eql [{ 'name' => "oil",
                 'description' => "the reason for our planet's demise",
                 'id' => 1 }]
  end

  it "doesn't retrieve tags applied to objects of other classes" do
    test_tagable.tag("oil")
    Tagging.create!(tag_id: 2, tagable_class: 'AnotherClass', tagable_id: test_tagable.id)
    expect(test_tagable.tags.length).to eq 1
  end

  it "can retrieve taggings" do
    test_tagable.tag("oil")
    expect(test_tagable.taggings.to_a).to eq [Tagging.last]
  end

  it "can be tagged with an existing tag's id" do
    expect { test_tagable.tag(1) }.to change { Tagging.count }.by(1)
    expect(test_tagable.tags[0][:name]).to eq 'oil'
  end

  it "cannot be tagged with a non-existent tag id or name" do
    expect { test_tagable.tag("THIS IS NOT A REAL TAG!!!!") }.to raise_error(Tag::NonexistentTagError)
    expect { test_tagable.tag(1_000_000) }.to raise_error(Tag::NonexistentTagError)
  end

  xit "is applicable to Entity, List, Relationship" do
  end
end
