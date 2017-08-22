require "rails_helper"

describe "partial: sidebar" do
  before(:all) do
    Tagging.skip_callback(:save, :after, :update_tagable_timestamp)
  end

  after(:all) do
    Tagging.set_callback(:save, :after, :update_tagable_timestamp)
  end

  let(:org) do
    build(:org, org: build(:organization), id: rand(1000))
  end

  before do
    allow(Entity).to receive(:search).and_return([])
  end

  describe 'layout' do
    before do
      assign(:entity, org)
      render partial: 'entities/sidebar.html.erb'
    end

    it 'renders partial sidebar/image' do
      expect(view).to render_template(partial: 'entities/sidebar/_image')
    end

    it 'has basic info' do
      css 'span.sidebar-title-text', text: 'Basic info'
    end
  end

  describe 'tags' do
    context 'entity has tags' do
      before do
        org.tag('oil')
        org.tag('nyc')
        assign(:entity, org)
        render partial: 'entities/sidebar.html.erb'
      end

      it 'has #tags-container' do
        css '#tags-container'
      end
    end

    context 'entity does not have tags' do
      before do
        assign(:entity, org)
        render partial: 'entities/sidebar.html.erb'
      end

      it 'does not have #tags-container' do
        not_css '#tags-container'
      end
    end
  end

  describe 'When signed in but not admin' do
    context 'all users' do
      before do
        assign(:entity, org)
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user).and_return(double(:admin? => false, :importer? => false, :merger? => false))
        render partial: 'entities/sidebar.html.erb'
      end

      it 'has Advanced tools' do
        css 'span.sidebar-title-text', text: 'Advanced tools'
      end

      it 'has network search' do
        css 'a', text: 'Network Search'
      end

      it 'has find connections' do
        css 'a', text: 'Find Connections'
      end

      it 'does not have Match NY Donations' do
        not_css 'a', text: 'Match NY Donations'
      end
    end

    context 'with importer permission' do
      before do
        assign(:entity, org)
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user).and_return(double(:admin? => false, :importer? => true, :merger? => false))
        render partial: 'entities/sidebar.html.erb'
      end

      it 'has Match NY Donations' do
        css 'a', text: 'Match NY Donations'
      end
    end

    context 'with merger permission' do
      before do
        assign(:entity, org)
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user).and_return(double(:admin? => false, :importer? => false, :merger? => true))
        render partial: 'entities/sidebar.html.erb'
      end

      it 'has merge link' do
        css 'a', text: 'Merge this entity'
      end
    end
  end

  describe 'Admin tools' do
    context 'When admin' do
      before do
        assign(:entity, org)
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user).and_return(double(:admin? => true, :importer? => false, :merger? => false))
        render partial: 'entities/sidebar.html.erb'
      end

      it 'has admin tools' do
        css 'span.sidebar-title-text', text: 'Admin tools'
        css 'a', text: 'Addresses'
     end
    end

    context 'When not admin' do
      before do
        assign(:entity, org)
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user).and_return(double(:admin? => false, :importer? => false, :merger? => false))
        render partial: 'entities/sidebar.html.erb'
      end

      it 'does not have admin tools' do
        not_css 'span.sidebar-title-text', text: 'Admin tools'
      end
    end
  end

  describe 'similar entities' do
    before { assign(:entity, org) }
    it 'has merging process link' do
      allow(view).to receive(:user_signed_in?).and_return(true)
      assign(:similar_entities, ['some', 'similar', 'entities'])
      expect(view).to receive(:sidebar_similar_entities)
      current_user = build(:user)
      expect(current_user).to receive(:admin?).at_least(:twice).and_return(false)
      allow(current_user).to receive(:importer?).and_return(false)
      expect(current_user).to receive(:has_legacy_permission).at_least(:once).with('merger').and_return(true)
      expect(view).to receive(:current_user).at_least(:twice).and_return(current_user)
      render partial: 'entities/sidebar.html.erb' 
    end
  end
end
