describe ToolkitPage, type: :model do
  it { should belong_to(:last_user).optional }

  describe 'pagify_name' do
    it 'converts to lowercase and replaces spaces with underscores' do
      expect(ToolkitPage.pagify_name('My Name')).to eq 'my_name'
    end
  end

  describe 'validations' do
    subject { ToolkitPage.new(name: "page") }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_presence_of(:name) }
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
