describe 'lists/header', :tag_helper, type: :view do

  let(:tags) { [] }
  let(:list) do
    list = build(:list)
    allow(list).to receive(:tags).and_return(tags)
    list
  end

  before(:each) do
    allow(view).to receive(:user_admin?).and_return(true)
    render partial: 'lists/header', locals: { list: list }
  end

  context 'list has no tags' do
    it 'does not show the tags component' do
      expect(view).not_to render_template(:partial => "lists/_tags")
    end

    it 'does not have the tags column wrapper' do
      not_css 'div.col-sm-4'
    end
  end

  context 'list has 1 tag' do
    let(:tags) { [Tag.create!(TagSpecHelper::OIL_TAG)] }

    it 'renders tag partial' do
      expect(view).to render_template(:partial => "lists/_tags", :locals => { tags: tags })
    end
  end

  context 'list has 3 tag' do
    let(:tags) { TagSpecHelper::TAGS.map { |t| Tag.create!(t) } }

    it 'renders template lists/tags with the title' do
      expect(view).to render_template(:partial => "lists/_tags",
                                      :locals => { tags: tags, include_title: true })
      css 'h4', text: 'Tags'
    end

    it 'shows tags on right' do
      not_css '#list-name div.col-sm-12'
      css '#list-name div.col-sm-8'
    end
  end
end
