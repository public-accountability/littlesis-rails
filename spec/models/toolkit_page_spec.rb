require 'rails_helper'

describe ToolkitPage, type: :model do
  describe 'validations' do
    subject { ToolkitPage.new(name: "page") }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_presence_of(:name) }
    it { should belong_to(:last_user) }
  end

  describe 'set_markdown_to_be_blank_string_if_null' do
    it 'sets markdown to be "" if created with nil' do
      page1 = ToolkitPage.create!(name: 'page1')
      expect(ToolkitPage.find(page1.id).markdown).to eq ""
      page2 = ToolkitPage.create!(name: 'page2', markdown: '# i exist')
      expect(ToolkitPage.find(page2.id).markdown).to eq '# i exist'
      page2.update(markdown: 'new value')
      expect(ToolkitPage.find(page2.id).markdown).to eq 'new value'
    end
  end

  describe '#modify_name' do
    it 'changes name' do
      page1 = ToolkitPage.create!(name: 'Page Name')
      page2 = ToolkitPage.create!(name: 'good_name')
      page3 = ToolkitPage.create!(name: 'okay')
      page4 = ToolkitPage.create(name: nil)
      page5 = ToolkitPage.create!(name: 'multi word name')
      expect(page1.name).to eq 'page_name'
      expect(page2.name).to eq 'good_name'
      expect(page3.name).to eq 'okay'
      expect(page4.name).to be nil
      expect(page5.name).to eq 'multi_word_name'
    end
  end
end
