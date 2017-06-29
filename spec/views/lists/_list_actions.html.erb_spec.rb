require 'rails_helper'

describe 'partial: lists/list_actions', :type => :view do
  before(:all) do
    @lister = create_list_user
    @admin = create_admin_user
  end

  context 'regular list and user with lister permission' do
    before do
      allow(view).to receive(:current_user).and_return(@lister)
      render partial: 'lists/list_actions.html.erb', locals: { list: build(:list) }
    end

    it 'has edit button' do
      css 'a', text: 'edit'
    end

    it 'does not have delete button' do
      not_css 'a', text: 'delete'
    end

    it 'has entity input' do
      css 'input#add-entity-input', count: 1
    end
  end

  context 'user is not signed in' do
    before do
      render partial: 'lists/list_actions.html.erb', locals: {list: build(:list) }
    end

    it 'does not have list-actions' do
      not_css 'div.list-actions'
    end
  end

  context 'user is not signed in and the list is admin' do
    before do
      render partial: 'lists/list_actions.html.erb', locals: { list: build(:list, is_admin: true) }
    end

    it 'does not have list-actions' do
      not_css 'div.list-actions'
    end
  end

  context 'admin list' do
    context 'user is admin' do
      before do
        allow(view).to receive(:current_user).and_return(@admin)
        render partial: 'lists/list_actions.html.erb', locals: { list: build(:list, is_admin: true) }
      end

      it 'has list-actions' do
        css 'div.list-actions', count: 1
      end

      it 'has delete button' do
        css 'a', text: 'delete'
      end
    end

    context 'user is not admin' do
      before do
        allow(view).to receive(:current_user).and_return(@lister)
        render partial: 'lists/list_actions.html.erb', locals: { list: build(:list, is_admin: true) }
      end

      it 'does not have list-actions' do
        not_css 'div.list-actions'
      end
    end
  end
end
