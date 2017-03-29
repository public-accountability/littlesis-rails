require 'rails_helper'

describe 'relationships/show.html.erb', type: :view do
  before(:all) do
    @sf_user = build(:sf_guard_user)
    @user = build(:user)
    @sf_user.user = @user
    @rel = build(:relationship, category_id: 1, description1: 'boss', id: 123, updated_at: Time.now)
    @rel.position = build(:position, is_board: false)
    @rel.last_user = @sf_user
  end

  describe 'layout' do

    before do
      assign(:relationship, @rel)
      expect(@rel).to receive(:source_links).and_return([])
      render
    end

    it 'has title' do 
      css 'h1', :text => "Position: Human Being, mega corp LLC"
    end

    it 'has subtitle' do 
      css 'h4 a', :count => 2
    end
    
    it 'has source links table' do 
      css '#source-links-table', :count => 1
    end

    describe 'actions' do 
      it 'has actions div' do 
        css '#actions'
      end

      it 'has edited history' do 
        css '#entity-edited-history'
        css 'a', :text => 'user'
      end
    end
  end

  describe 'Add Reference Modal' do
    before do
      @current_user = double('user')
      allow(@current_user).to receive(:has_legacy_permission).and_return(true)
      assign(:relationship, @rel)
      assign(:current_user, @current_user)
      allow(view).to receive(:user_signed_in?).and_return(true)
      render
    end

    it 'has modal and form' do
      css '#add-reference-modal'
      css 'form', :count => 1
    end

    it 'has hidden inputs' do
      expect(rendered).to have_tag 'input[value="Relationship"]', :count => 1
      expect(rendered).to have_tag 'input#data_object_id', :count => 1
    end

    it 'has url field' do
      css 'input[type="url"]', :count => 1
    end

    it 'has 2 text fields' do
      css 'input[type="text"]', :count => 2
    end

    it 'has select field with 3 options' do
      css 'select', :count => 1
      css 'option', :count => 3
    end

    it 'has text area' do
      css 'textarea', :count => 1
    end

    it 'has close and submit buttons' do
      css 'button', :text => 'Close'
      css 'input[type="submit"]', :count => 1
    end
  end
end
