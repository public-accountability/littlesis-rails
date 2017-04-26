require 'rails_helper'

describe ApplicationHelper, :type => :helper do
  describe 'page_title' do
    it 'should generate correct title' do
      expect(helper).to receive(:content_for?).with(:page_title).and_return(true)
      expect(helper).to receive(:content_for).with(:page_title).and_return('this is the page title')
      expect(helper.page_title).to eq 'this is the page title - LittleSis'
    end

    it 'sets title to be LittleSis by default' do
      expect(helper).to receive(:content_for?).with(:page_title).and_return(false)
      expect(helper.page_title).to eq 'LittleSis'
    end
  end

  describe 'yes_or_no' do
    it 'turns boolean into yes or no' do
      expect(helper.yes_or_no(true)).to eq 'yes'
      expect(helper.yes_or_no(false)).to eq 'no'
    end
  end

end
