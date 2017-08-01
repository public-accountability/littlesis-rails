require "rails_helper"

describe "partial: entities/actions" do
  context 'when user is an advanced user' do
    before(:all) do
      @org = build(:org, updated_at: 1.day.ago, last_user: build(:sf_user, user: build(:user)))
      @person = build(:person, updated_at: 1.day.ago, last_user: build(:sf_user, user: build(:user)))
    end

    before(:each) do
      expect(view).to receive(:user_signed_in?).and_return(true)
      user = build(:user)
      expect(user).to receive(:has_legacy_permission).with('deleter').and_return(true)
      expect(user).to receive(:has_legacy_permission).with('importer').and_return(true)
      expect(user).to receive(:has_legacy_permission).with('bulker').and_return(true)
      allow(user).to receive(:has_legacy_permission).with('admin').and_return(false)
      assign(:current_user, user)
    end

    it 'has remove link' do
      assign(:entity, @org)
      render partial: 'entities/actions.html.erb'
      css 'input[value=remove]'
    end

    it 'has add bulk link' do
      assign(:entity, @org)
      render partial: 'entities/actions.html.erb'
      css 'a', text: 'add bulk'
    end

    it 'has match donations link if entity is a person' do
      assign(:entity, @person)
      render partial: 'entities/actions.html.erb'
      css 'a', text: 'match donations'
    end

    it ' does not have match donations link if the entity is an org' do
      assign(:entity, @org)
      render partial: 'entities/actions.html.erb'
      not_css 'a', text: 'match donations'
    end
  end

  context 'when user is not signed in' do
    before do
      expect(view).to receive(:user_signed_in?).and_return(false)
      org = build(:org,
                  updated_at: 1.day.ago,
                  last_user: build(:sf_user, user: build(:user)))
      assign(:entity, org)
      render partial: 'entities/actions.html.erb'
    end

    it 'contains add relationship button' do
      css 'a', text: 'add relationship'
    end

    it 'contains edit button' do
      css 'a', text: 'edit'
    end

    it 'contains flag button' do
      css 'a', text: 'flag'
    end

    it 'renders entity history' do
      expect(view).to render_template(:partial => "shared/_entity_history")
    end
  end
end
