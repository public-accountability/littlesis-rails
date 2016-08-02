require 'rails_helper'

describe Entity do
  describe 'summary_excerpt' do 
    
    it 'returns nil if there is no summary' do
      mega_corp = build(:mega_corp_inc, summary: nil)
      expect(mega_corp.summary_excerpt).to be_nil
    end
    
    it 'truncates to under 100 chars' do
      mega_corp = build(:mega_corp_inc, summary: 'word ' * 50)
      expect(mega_corp.summary_excerpt.length).to be < 100
    end

    it 'returns just the first  paragraph even if the paragraph is less than 100 chars' do
      summary = ('x ' * 25) + "\n" + ('word ' * 25)
      mega_corp = build(:mega_corp_inc, summary: summary)
      expect(mega_corp.summary_excerpt.length).to eql(53)
      expect(mega_corp.summary_excerpt).to eql(('x ' * 25) + '...')
    end
  end
end
