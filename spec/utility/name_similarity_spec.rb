require 'rails_helper'

describe NameSimilarity do
  it 'raises TypeError unless both arguments are strings' do
    expect { NameSimilarity.new('hello', 123) }.to raise_error(TypeError)
  end

  it 'has factory class method "compare"' do
    expect(NameSimilarity.compare('xyz', 'abc')).to be_a NameSimilarity
  end

  context 'names are the same' do
    subject { NameSimilarity.new('alice', 'alice') }
    assert_attribute :equal, true
    assert_attribute :similar, true
    
    context 'with different capitalization' do
      subject { NameSimilarity.new('alIcE', 'alice') }
      assert_attribute :equal, true
      assert_attribute :similar, true
    end
  end

  context 'names are almost the same' do
    subject { NameSimilarity.new('aice', 'alice') }
    assert_attribute :equal, false
    assert_attribute :similar, true
    assert_attribute :levenshtein, 1
    assert_attribute :first_name_alias, nil
  end

  context 'names are totally different' do
    subject { NameSimilarity.new('bob', 'alice') }
    assert_attribute :equal, false
    assert_attribute :similar, false
    assert_attribute :levenshtein, 5
  end

  context 'similar first names' do
    subject { NameSimilarity.new('ag', 'agatha', first_name: true) }
    assert_attribute :equal, false
    assert_attribute :levenshtein, 4
    assert_attribute :similar, true
    assert_attribute :first_name_alias, true
    context 'reversed' do
      subject { NameSimilarity.new('agatha', 'ag', first_name: true) }
      assert_attribute :similar, true
      assert_attribute :first_name_alias, true
    end
  end
end
