module NameParserMacros
  BLANK_NAME_HASH = {
    name_prefix: nil,
    name_first: nil,
    name_middle: nil,
    name_last: nil,
    name_suffix: nil,
    name_nick: nil
  }.freeze

  def assert_parsed_name(input, **expected)
    output = BLANK_NAME_HASH
               .merge(expected.map { |k, v| ["name_#{k}".to_sym, v] }.to_h)

    it "correctly parses #{input}" do
      expect(NameParser.new(input).to_h).to eql output
    end
  end
end
