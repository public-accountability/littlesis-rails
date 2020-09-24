require 'os_committee_importer'

describe 'OsCommitteeImporter' do
  describe 'line_to_a' do
    before do
      @line_output = OsCommitteeImporter.line_to_a("|2004|,|C00000059|,|Hallmark Cards|,,|Hallmark Cards|,|C00000059|,|PB|,||,,|C1400|,|Hoovers|,|N|,|0|,1")
    end

    it 'converts line to array' do
      expect(@line_output).to be_a(Array)
    end

    it 'has correct number of fields' do
      expect(@line_output.length).to eql 14
    end
  end

  describe 'process_line' do
    before do
      @count = OsCommittee.count
      OsCommitteeImporter.process_line("|2004|,|C00000059|,|Hallmark Cards|,,|Hallmark Cards|,|C00000059|,|PB|,||,,|C1400|,|Hoovers|,|N|,|0|,1")
    end

    it 'creates a new record' do
      expect(OsCommittee.count).to eql(@count + 1)
    end

    it 'record has correct fields' do
      cmte = OsCommittee.last
      expect(cmte.cycle).to eq '2004'
      expect(cmte.cmte_id).to eq 'C00000059'
      expect(cmte.recipcode).to eq 'PB'
      expect(cmte.feccandid).to be_nil
      expect(cmte.party).to be_nil
      expect(cmte.primcode).to eql 'C1400'
      expect(cmte.sensitive).to eql(false)
      expect(cmte.foreign).to eql(false)
      expect(cmte.active_in_cycle).to eql(true)
    end

    it 'can be inserted twice without creating duplicates' do
      OsCommitteeImporter.process_line("|2004|,|C00000059|,|Hallmark Cards|,,|Hallmark Cards|,|C00000059|,|PB|,||,,|C1400|,|Hoovers|,|N|,|0|,1")
      expect(OsCommittee.count).to eql(@count + 1)
    end
  end
end
