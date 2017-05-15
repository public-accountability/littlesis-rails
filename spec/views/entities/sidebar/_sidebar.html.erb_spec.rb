require "rails_helper"

describe "partial: sidebar" do
  before do
    allow(Entity).to receive(:search).and_return([])
    org = build(:org, org: build(:organization), id: rand(1000))
    assign(:entity, org)
  end

  describe 'layout' do
    before { render partial: 'entities/sidebar.html.erb' }

    it 'renders partial sidebar/image' do
      expect(view).to render_template(partial: 'entities/sidebar/_image')
    end

    it 'has basic info' do
      css 'span.sidebar-title-text', text: 'Basic info'
    end
  end

  describe 'When signed in but not admin' do
    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(double(:admin? => false))
      render partial: 'entities/sidebar.html.erb'
    end

    it 'has Advanced tools' do
      css 'span.sidebar-title-text', text: 'Advanced tools'
    end
  end


  describe 'Admin tools' do
    context 'When admin' do
      before do
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user).and_return(double(:admin? => true))
        render partial: 'entities/sidebar.html.erb'
      end

      it 'has admin tools' do
        css 'span.sidebar-title-text', text: 'Admin tools'
        css 'a', text: 'Addresses'
      end
    end

    context 'When not admin' do
      before do
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user).and_return(double(:admin? => false))
        render partial: 'entities/sidebar.html.erb'
      end

      it 'has admin tools' do
        not_css 'span.sidebar-title-text', text: 'Admin tools'
      end
    end
  end

  describe 'similar entities' do
    it 'has merging process link' do
      allow(view).to receive(:user_signed_in?).and_return(true)
      assign(:similar_entities, ['some', 'similar', 'entities'])
      expect(view).to receive(:sidebar_similar_entities)
      current_user = build(:user)
      expect(current_user).to receive(:admin?).at_least(:twice).and_return(false)
      expect(current_user).to receive(:has_legacy_permission).with('merger').and_return(true)
      expect(view).to receive(:current_user).at_least(:twice).and_return(current_user)
      render partial: 'entities/sidebar.html.erb' 
    end
  end
end
