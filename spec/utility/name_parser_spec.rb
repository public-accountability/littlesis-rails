require 'rails_helper'

describe 'NameParser' do
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
