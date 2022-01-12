describe 'lists/list_actions', :type => :view do
  context 'when not editable' do
    before do
      assign(:list, create(:list))
      assign(:permissions, { :editable => false })
      render partial: 'lists/list_actions', locals: { list: build(:list) }
    end

    it 'renders only the removal button' do
      within '.list-actions' do
        expect(rendered).to have_css('a', text: 'request removal')
        expect(rendered).to have_css('a', count: 1)
      end
    end
  end

  context 'when editable' do
    before do
      assign(:list, create(:list))
      assign(:permissions, { :editable => true, :configurable => false })
      render partial: 'lists/list_actions', locals: { list: build(:list) }
    end

    it 'has list-actions div' do
      css 'div.list-actions'
    end

    it 'does not have edit button' do
      not_css 'a', text: 'edit'
    end

    it 'has entity select' do
      css 'select', count: 1
    end

    it 'does not have delete button' do
      not_css 'input[value="delete"]'
    end
  end

  context 'when configurable' do
    before do
      assign(:list, create(:list))
      assign(:permissions, { :editable => true, :configurable => true })
      render partial: 'lists/list_actions', locals: { list: build(:list) }
    end

    it 'has edit button' do
      css 'a', text: 'edit'
    end

    it 'has delete button' do
      css 'input[value="delete"]'
    end
  end
end
