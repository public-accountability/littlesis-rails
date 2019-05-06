describe 'partial: lists/list_actions', :type => :view do
  context 'NOT EDITABLE' do
    before do
      assign(:permissions, { :editable => false})
      render partial: 'lists/list_actions.html.erb', locals: { list: build(:list) }
    end
    it 'renders NOTHING' do
      expect(rendered).to eq ''
    end
  end

  context 'EDITABLE' do
    before do
      assign(:permissions, { :editable => true, :configurable => false })
      render partial: 'lists/list_actions.html.erb', locals: { list: build(:list) }
    end

    it 'has list-actions div' do
      css 'div.list-actions'
    end

    it 'does not have edit button' do
      not_css 'a', text: 'edit'
    end

    it 'has entity input' do
      css 'input#add-entity-input', count: 1
    end

    it 'does not have delete button' do
      not_css 'a', text: 'delete'
    end
  end

  context 'configurable' do
    before do
      assign(:permissions, { :editable => true, :configurable => true })
      render partial: 'lists/list_actions.html.erb', locals: { list: build(:list) }
    end

    it 'has edit button' do
      css 'a', text: 'edit'
    end

    it 'has delete button' do
      css 'a', text: 'delete'
    end
  end
end
