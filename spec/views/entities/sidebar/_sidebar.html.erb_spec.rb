describe "partial: sidebar", :tag_helper do
  seed_tags

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
      render partial: 'entities/sidebar'
    end

    it 'renders partial sidebar/image' do
      expect(view).to render_template(partial: 'entities/sidebar/_image')
    end

    it 'has basic info' do
      css 'span.sidebar-title-text', text: 'Basic info'
    end
  end

  describe 'tags' do
    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user)
                      .and_return(double(:admin? =>      true,
                                         :importer? =>   true,
                                         :merger? =>     false,
                                         :permissions => double(:tag_permissions => {})))

    end
    context 'entity has tags' do
      before do
        org.add_tag('oil')
        org.add_tag('nyc')
        assign(:entity, org)
        render partial: 'entities/sidebar'
      end

      it 'has #tags-container' do
        css '#tags-container'
      end
    end
  end

  describe 'When signed in but not admin' do
    context 'all users' do
      before do
        assign(:entity, org)
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user)
                        .and_return(double(:admin? =>      false,
                                           :importer? =>   false,
                                           :merger? =>     false,
                                           :permissions => double(:tag_permissions => {})))

        render partial: 'entities/sidebar'
      end

      it 'has Advanced tools' do
        css 'span.sidebar-title-text', text: 'Advanced tools'
      end

      it 'does not have Match NY Donations' do
        not_css 'a', text: 'Match NY Donations'
      end
    end

    context 'with importer permission' do
      before do
        assign(:entity, org)
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user)
                        .and_return(double(:admin? =>      false,
                                           :importer? =>   true,
                                           :merger? =>     false,
                                           :permissions => double(:tag_permissions => {})))

        render partial: 'entities/sidebar'
      end

      it 'has Match NY Donations' do
        css 'a', text: 'Match NY Donations'
      end
    end

    context 'with merger permission' do
      before do
        assign(:entity, org)
        allow(view).to receive(:user_signed_in?).and_return(true)
        allow(view).to receive(:current_user)
                        .and_return(double(:admin? =>      false,
                                           :importer? =>   false,
                                           :merger? =>     true,
                                           :permissions => double(:tag_permissions => {})))

        render partial: 'entities/sidebar'
      end
    end
  end
end
