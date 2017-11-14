require 'rails_helper'

feature 'help pages' do
  let(:index_page) { create(:help_page, name: 'index', markdown: '# help pages', title: 'help pages') }

  scenario 'visting the help pages index' do
    visit "/help"
    expect(page.status_code).to eq 200
    page_has_selector 'h1', text: 'LittleSis Help'
  end
end
