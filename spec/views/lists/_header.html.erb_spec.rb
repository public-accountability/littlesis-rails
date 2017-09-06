require 'rails_helper'

describe 'partial: lists/header', :tag_helper, type: :view do
  seed_tags
  
  let(:tags) { [] }
  let(:list) do
    list = build(:list)
    allow(list).to receive(:tags).and_return(tags)
    list
  end

  before(:each) do
    allow(view).to receive(:user_admin?).and_return(true)
    render partial: 'lists/header.html.erb', locals: { list: list }
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
    let(:tags) { Tag.all.take(1) }

    it 'renders tag partial without the title ' do
      expect(view).to render_template(:partial => "lists/_tags", :locals => { tags: tags })
      not_css 'h4'
    end

    it 'shows tags on same row with title' do
      css '#list-name div.col-sm-12'
      not_css '#list-name div.col-sm-8'
    end
  end

  context 'list has 3 tag' do
    let(:tags) { Tag.all.take(3) }

    it 'renders template lists/tags with the title' do
      expect(view).to render_template(:partial => "lists/_tags",
                                      :locals => { tags: tags, include_title: true })
      css 'h4', text: 'Tags'
    end

    it 'shows tags on same row with title' do
      not_css '#list-name div.col-sm-12'
      css '#list-name div.col-sm-8'
    end
  end
end
