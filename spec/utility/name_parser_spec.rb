require 'rails_helper'

describe 'NameParser', :name_parser_helper do
  describe 'parse' do
    assert_parsed_name 'god', last: 'God'
    assert_parsed_name 'Wendell Phillips', last: 'Phillips', first: 'Wendell'
    assert_parsed_name 'Phillips, Wendell', last: 'Phillips', first: 'Wendell'
    assert_parsed_name 'Mayor blah', last: 'Blah', prefix: 'Mayor'
    assert_parsed_name 'Ruperta Chirpingden-Groin', first: 'Ruperta', last: 'Chirpingden-Groin'
    assert_parsed_name 'anna garlin spencer', last: 'Spencer', first: 'Anna', middle: 'Garlin'
    assert_parsed_name 'anna "garlin" spencer', last: 'Spencer', first: 'Anna', nick: 'Garlin'
    assert_parsed_name 'Ida B. Wells', first: 'Ida', middle: 'B', last: 'Wells'
    assert_parsed_name 'Dr. Ethel Bentham', prefix: 'Dr', first: 'Ethel', last: 'Bentham'
    assert_parsed_name 'Bentham, Dr. Ethel', prefix: 'Dr', first: 'Ethel', last: 'Bentham'

    assert_parsed_name 'Jane Doe III', first: 'Jane', last: 'Doe', suffix: 'III'
    assert_parsed_name 'Jane Doe, III', first: 'Jane', last: 'Doe', suffix: 'III'
    assert_parsed_name 'Doe Sr, Jane', first: 'Jane', last: 'Doe', suffix: 'SR'
    assert_parsed_name 'Doe Sr, Sen. Jane', first: 'Jane', last: 'Doe', suffix: 'SR', prefix: 'Sen'
    assert_parsed_name 'John A Doe', first: 'John', middle: 'A', last: 'Doe'
    assert_parsed_name 'John A. Doe', first: 'John', middle: 'A', last: 'Doe'
    assert_parsed_name 'Jane "J" Doe III', first: 'Jane', last: 'Doe', suffix: 'III', nick: 'J'

    assert_parsed_name 'Pavel "Fyodor" Fyodorovitch Smerdyakov',
                       first: 'Pavel', middle: 'Fyodorovitch', last: 'Smerdyakov', nick: 'Fyodor'

    assert_parsed_name 'Dr. John A. Kenneth Doe, Jr.',
                       prefix: 'Dr', first: 'John', middle: 'A. Kenneth', last: 'Doe', suffix: 'JR'

    assert_parsed_name 'John A. Doe, Jr', first: 'John', middle: 'A', last: 'Doe', suffix: 'JR'

    assert_parsed_name 'Doctor Martin Luther King',
                       prefix: 'Doctor', first: 'Martin', middle: 'Luther', last: 'King'

    assert_parsed_name "Jane with way too many middle names doe",
                       first: "Jane", last: 'Doe', middle: 'With Way Too Many Middle Names'
  end

  describe 'parse_to_hash' do
    it 'parses valid name' do
      expect(NameParser.parse_to_hash("emma goldman"))
        .to eql(name_prefix: nil,
                name_first: 'Emma',
                name_middle: nil,
                name_last: 'Goldman',
                name_suffix: nil,
                name_nick: nil)
    end

    it 'returns false for invalid names' do
      expect(NameParser.parse_to_hash("emma")).to be false
    end
  end

  describe 'parse to person' do
    subject { NameParser.parse_to_person('Hannah Arendt') }
    it { is_expected.to be_a Person }
    specify { expect(subject.name_first).to eql 'Hannah' }
    specify { expect(subject.name_last).to eql 'Arendt' }
  end

  describe 'os_parse' do
    it 'parses "CAT, ALICE"' do
      x = NameParser.os_parse("CAT, ALICE")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to be_nil
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end

    it 'parses "CAT, ALICE M"' do
      x = NameParser.os_parse("CAT, ALICE M")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to eql("M")
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end

    it 'parses "CAT, ALICE THE"' do
      x = NameParser.os_parse("CAT, ALICE THE")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to eq("The")
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end

    it 'parses "CAT, ALICE IV"' do
      x = NameParser.os_parse("CAT, ALICE IV")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to be_nil
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to eq("IV")
    end

    it 'parses "CAT, ALICE MS"' do
      x = NameParser.os_parse("CAT, ALICE MS")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to be_nil
      expect(x[:prefix]).to eq('Ms')
      expect(x[:suffix]).to be_nil
    end

    it 'parses "CAT, ALICE THE IV"' do
      x = NameParser.os_parse("CAT, ALICE THE IV")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to eq("The")
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to eq("IV")
    end

    it 'parses "CAT, ALICE E CAPT"' do
      x = NameParser.os_parse("CAT, ALICE E CAPT")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to eq("E")
      expect(x[:prefix]).to eq("Capt")
      expect(x[:suffix]).to be_nil
    end

    it 'parses "CAT, ALICE DOUBLE MIDDLE"' do
      x = NameParser.os_parse("CAT, ALICE DOUBLE MIDDLE")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to eq("Double Middle")
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end

    it 'parses "ALICE CAT"' do
      x = NameParser.os_parse("ALICE CAT")
      expect(x[:first]).to eq("Alice")
      expect(x[:last]).to eq("Cat")
      expect(x[:middle]).to be_nil
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end

    it 'parses a blank string' do
      x = NameParser.os_parse("")
      expect(x[:first]).to be_nil
      expect(x[:last]).to be_nil
      expect(x[:middle]).to be_nil
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end

    it 'return nil if nil' do
      x = NameParser.os_parse(nil)
      expect(x[:first]).to be_nil
      expect(x[:last]).to be_nil
      expect(x[:middle]).to be_nil
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end

    it 'parses name with an extra comma' do
      x = NameParser.os_parse("CAT,,ALICE")
      expect(x[:first]).to eql('Alice')
      expect(x[:last]).to eql('Cat')
      expect(x[:middle]).to be_nil
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end

    it 'parses names with an extra comma and a middle name' do
      x = NameParser.os_parse("CAT,,ALICE S")
      expect(x[:first]).to eql('Alice')
      expect(x[:last]).to eql('Cat')
      expect(x[:middle]).to eql('S')
      expect(x[:prefix]).to be_nil
      expect(x[:suffix]).to be_nil
    end
  end
end
