require 'rails_helper'

describe Tag, :tag_helper do
  seed_tags

  it { should have_db_column(:restricted) }
  it { should have_db_column(:name) }
  it { should have_db_column(:description) }
  it { should have_many(:taggings) }

  describe 'validations' do
    subject { Tag.new(name: 'fake tag name', description: 'all about fake tags') }

    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end

  it 'can determine if a tag is restricted' do
    expect(Tag.find_by_name('oil').restricted?).to be false
    expect(Tag.find_by_name('nyc').restricted?).to be true
  end

  it 'partitions tag ids from client into hash of update actions to be taken' do
    client_ids = [1, 2, 3].to_set
    server_ids = [2, 3, 4].to_set
    expect(Tag.parse_update_actions(client_ids, server_ids)).to eql(
      add: [1].to_set,
      remove: [4].to_set,
      ignore: [2, 3].to_set
    )
  end
end
