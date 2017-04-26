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

  describe 'facebook_meta' do
    it 'generates one meta tag' do
      expect(helper).to receive(:content_for).with(:facebook_url)
      expect(helper).to receive(:content_for).with(:facebook_type)
      expect(helper).to receive(:content_for).with(:facebook_title).and_return('page title')
      expect(helper).to receive(:content_for).with(:facebook_description)
      expect(helper).to receive(:content_for).with(:facebook_image)
      expect(helper.facebook_meta).to eq '<meta property="og:title" content="page title" />'
    end

    it 'generates two meta tags' do
      expect(helper).to receive(:content_for).with(:facebook_url).and_return('http://example.com')
      expect(helper).to receive(:content_for).with(:facebook_type)
      expect(helper).to receive(:content_for).with(:facebook_title).and_return('page title')
      expect(helper).to receive(:content_for).with(:facebook_description)
      expect(helper).to receive(:content_for).with(:facebook_image)
      expect(helper.facebook_meta)
        .to eq '<meta property="og:url" content="http://example.com" /><meta property="og:title" content="page title" />'
    end
  end

end
