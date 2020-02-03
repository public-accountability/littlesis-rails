describe StringSimilarity do
  it 'raises TypeError unless both arguments are strings' do
    expect { StringSimilarity.new('hello', 123) }.to raise_error(TypeError)
  end

  it 'has factory class method "compare"' do
    expect(StringSimilarity.compare('xyz', 'abc')).to be_a StringSimilarity
  end

  it 'class method #similar? as boolean shortcut ' do
    expect(StringSimilarity.similar?('little', 'sis')).to be false
    expect(StringSimilarity.similar?('sandy', 'sandi')).to be true
  end

  context 'when names are the same' do
    subject { StringSimilarity.new('alice', 'alice') }

    assert_attribute :equal, true
    assert_attribute :similar, true

    context 'with different capitalization' do
      subject { StringSimilarity.new('alIcE', 'alice') }

      assert_attribute :equal, true
      assert_attribute :similar, true
    end
  end

  context 'when names are almost the same' do
    subject { StringSimilarity.new('aice', 'alice') }

    assert_attribute :equal, false
    assert_attribute :similar, true
    assert_attribute :levenshtein, 1
  end

  context 'when names are totally different' do
    subject { StringSimilarity.new('bob', 'alice') }

    assert_attribute :equal, false
    assert_attribute :similar, false
    assert_attribute :levenshtein, 5
  end
end
