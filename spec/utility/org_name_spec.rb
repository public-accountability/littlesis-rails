describe OrgName do
  describe 'format' do
    specify do
      expect(OrgName.format("TWENTY-FIRST CENTURY FOX, INC."))
        .to eql "Twenty-First Century Fox, Inc."
    end

    specify do
      expect(OrgName.format("blah blah llc")).to eql "Blah Blah LLC"
    end

    specify do
      expect(OrgName.format("blahllc")).to eql "Blahllc"
    end

    specify do
      expect(OrgName.format("no suffix, here")).to eql "No Suffix, Here"
    end

    specify do
      expect(OrgName.format("hallmark cards pac")).to eql "Hallmark Cards PAC"
    end
  end

  describe 'parse' do
    specify { expect(OrgName.parse('ABC')).to be_a OrgName::Name }

    it 'parses "Liberty Mutual Insurance Group"' do
      name = OrgName.parse('Liberty Mutual Insurance Group')
      expect(name.original).to eql 'Liberty Mutual Insurance Group'
      expect(name.clean).to eql 'liberty mutual insurance group'
      expect(name.root).to eql 'liberty mutual insurance'
      expect(name.suffix).to eql 'group'
      expect(name.essential_words).to eql %w[liberty mutual]
    end

    it 'parses "Comcast"' do
      name = OrgName.parse 'Comcast.'
      expect(name.original).to eql 'Comcast.'
      expect(name.clean).to eql 'comcast'
      expect(name.suffix).to be_nil
      expect(name.root).to eql 'comcast'
      expect(name.essential_words).to eql ['comcast']
    end
  end

  describe 'strip_name_punctuation' do
    it 'removes commas and period' do
      expect(OrgName.strip_name_punctuation('TAKEDA PHARMACEUTICAL CO., LTD.'))
        .to eql 'TAKEDA PHARMACEUTICAL CO LTD'
    end

    it 'keeps periods if part of an url' do
      expect(OrgName.strip_name_punctuation('corp.com')).to eql 'corp.com'
    end

    it 'removes double-quotes' do
      expect(OrgName.strip_name_punctuation('US "BANK"')).to eql 'US BANK'
    end

    it 'replaces double spaces with single spaces' do
      expect(OrgName.strip_name_punctuation('XYZ  INC')).to eql 'XYZ INC'
    end
  end

  describe 'find_suffix' do
    specify { expect(OrgName.find_suffix('no suffix for me')).to be nil }
    specify { expect(OrgName.find_suffix('123 llc')).to eql 'llc' }
    specify { expect(OrgName.find_suffix('CORP LIMITED')).to eql 'LIMITED' }
    specify { expect(OrgName.find_suffix('123 llc-nation')).to be nil }
    specify do
      expect(OrgName.find_suffix('GAS NETWORKS HOLDINGS LIMITED'))
        .to eql 'HOLDINGS LIMITED'
    end

    specify do
      expect(OrgName.find_suffix("DC Capital Partners Management, L.P.")).to eql 'LP'
    end
  end

  describe 'find_root' do
    specify { expect(OrgName.find_root('no suffix for me')).to eql 'no suffix for me' }
    specify { expect(OrgName.find_root('123 llc')).to eql '123' }
    specify { expect(OrgName.find_root('CORP LIMITED')).to eql 'corp' }
    specify { expect(OrgName.find_root('123 llc-nation')).to eql'123 llc-nation' }
    specify do
      expect(OrgName.find_root('GAS NETWORKS HOLDINGS LIMITED'))
        .to eql 'gas networks'
    end
  end

  describe 'clean' do
    specify { expect(OrgName.clean('Company Name, LLC.')).to eql 'company name llc' }
    specify { expect(OrgName.clean('EXTERRAN CORPORATION')).to eql 'exterran corporation' }
    specify { expect(OrgName.clean('simplecorp')).to eql 'simplecorp' }
  end

  describe 'essential_words' do
    specify do
      expect(OrgName.essential_words("THE WEBSTER FINANCIAL CORP")).to eql %w[webster]
    end

    specify do
      expect(OrgName.essential_words("BAOSHAN IRON & STEEL COMPANY LIMITED")).to eql %w[baoshan iron steel]
    end

    specify do
      expect(OrgName.essential_words("the school of air")).to be_empty
    end
  end
end
