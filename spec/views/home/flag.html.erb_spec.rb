require 'rails_helper'

describe 'home/flag.html.erb', type: :view do
  context 'when referrer is missing' do
    before do
      assign(:referrer, nil)
      render
    end
    it 'has text_field_tag' do
      css 'input#url', count: 1
    end

    it 'does not have static url' do
      expect(rendered).not_to have_css('p.form-control-static')
    end
  end

  context 'when there is a referrer' do
    before do
      assign(:referrer, 'https://littlesis.org/some_page')
      render
    end

    it 'has static url' do
      css 'p.form-control-static', text: 'https://littlesis.org/some_page'
    end

    it 'has hidden url tag' do
      expect(rendered).to have_tag('input[type=hidden]', with: { value: 'https://littlesis.org/some_page' })
    end

    it 'does not has text_field_tag' do
      expect(rendered).not_to have_css('input#url')
    end
  end

  describe 'layout' do
    before { render }

    it 'has form' do
      css 'form', count: 1
    end

    it 'has submit' do
      expect(rendered).to have_tag('input[type=submit]', count: 1)
    end
  end
end
