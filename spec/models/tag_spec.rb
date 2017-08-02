require 'rails_helper'

describe Tag do
  let(:oil) do
    {
      'name' => 'oil',
      'description' => 'the reason for our planet\'s demise',
      'id' => 1
    }
  end

  let(:nyc) do
    {
      'name' => 'nyc',
      'description' => 'anything related to New York City',
      'id' => 2
    }
  end

  let(:tags) { [oil, nyc] }
  let(:invalid_tags) { tags.dup.tap { |t| t[1]['id'] = 1 } }

  it "returns all tags" do
    expect(Tag.all).to eql tags
  end

  describe 'invalid initialization' do
    before(:all) do
      Object.send(:remove_const, :Tag) # unload Tag class
    end

    after(:all) do
      Object.send(:remove_const, :Tag) # unload Tag class
      load Rails.root.join('app', 'models', 'tag.rb')
    end

    it "throws an argument error if ids not unique" do
      expect(YAML).to receive(:load).and_return(invalid_tags)
      expect {
        load Rails.root.join('app', 'models', 'tag.rb') # reload tag class
      }.to raise_error(ArgumentError)
    end
  end

  it 'generates a LOOKUP constant hash' do
    expect(Tag::LOOKUP)
      .to eq({
               1 => oil,
               'oil' => oil,
               2 => nyc,
               'nyc' => nyc
             })
  end

  it 'finds tags by id' do
    expect(Tag.find(1)).to eq oil
    expect(Tag.find(2)).to eq nyc
  end

  it 'finds tags by name' do
    expect(Tag.find('oil')).to eq oil
    expect(Tag.find('nyc')).to eq nyc
  end

  it 'handles non-existent ids or names' do
    expect(Tag.find('foobar')).to be nil
    expect(Tag.find(Integer::MAX_64BIT)).to be nil
  end

  it 'throws on non-existent ids or names' do
    expect { Tag.find!('foobar') } .to raise_error(Tag::NonexistentTagError)
    expect { Tag.find!(Integer::MAX_64BIT) }.to raise_error(Tag::NonexistentTagError)
  end

end
