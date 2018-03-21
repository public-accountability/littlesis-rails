require 'rails_helper'

describe ApplicationHelper, :type => :helper do
  describe 'page_title' do
    it 'should generate correct title' do
      expect(helper).to receive(:content_for)
                          .with(:page_title).once.and_return('this is the page title')
      expect(helper).to receive(:content_for?).with(:page_title).twice.and_return(true)
      expect(helper).to receive(:content_for?).with(:skip_page_title_suffix).twice.and_return(nil)
      expect(helper.page_title).to eq 'this is the page title - LittleSis'
    end

    it 'sets title to be LittleSis by default' do
      expect(helper).to receive(:content_for?).with(:page_title).twice.and_return(false)
      expect(helper).to receive(:content_for?)
                          .with(:skip_page_title_suffix).at_least(:once).and_return(nil)
      expect(helper.page_title).to eq 'LittleSis'
    end

    it 'can optionally skip "- LittleSis" suffix' do
      expect(helper).to receive(:content_for)
                          .with(:page_title).once.and_return('this is the page title')
      expect(helper).to receive(:content_for?).with(:page_title).twice.and_return(true)
      expect(helper).to receive(:content_for?).with(:skip_page_title_suffix).twice.and_return(true)
      expect(helper.page_title).to eq 'this is the page title'
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

  describe 'references_select' do
    let(:references) { Array.new(2) { build(:reference) } }
    let(:selected_id) { nil }
    subject { helper.references_select(references, selected_id) }

    context 'with no selected_id' do
      it { is_expected.to have_css 'option', count: 3 }
      it { is_expected.to have_css 'select.selectpicker' }
      it do
        is_expected.to have_css "option[value='#{references.first.id}']",
                                text: references.first.document.name
      end
      it do
        is_expected.to have_css "option[value='#{references.second.id}']",
                                text: references.second.document.name
      end
      it { is_expected.not_to include 'selected' }
    end

    context 'with a selected_id' do
      let(:selected_id) { references.first.id }
      it { is_expected.to have_css "option[value='#{references.first.id}'][selected='selected']" }
      it { is_expected.to have_css "option[value='#{references.second.id}']" }
    end
  end
end
