describe 'entities/show.html.erb' do
  before(:all) do
    DatabaseCleaner.start
    @user = create(:user)
  end
  after(:all) { DatabaseCleaner.clean }

  def sorted_links(e)
    SortedLinks.new(e)
  end

  context 'switching tabs' do
    before do
      assign(:active_tab, active_tab)
      entity = build(:org, last_user_id: @user.id, updated_at: 1.day.ago, org: build(:organization))
      expect(entity).to receive(:similar_entities).and_return([])
      assign(:entity, entity)
      render
    end

    context 'on relationships tab' do
      let(:active_tab) {  'relationships' }
      it { should render_template('entities/_relationships') }
    end

    context 'on interlocks tab' do
      let(:active_tab) {  'interlocks' }
      it { should render_template('entities/_interlocks') }
    end
  end

  context 'relationships tab' do
    before(:each) do
      assign(:active_tab, 'relationships')
      allow(Entity).to receive(:search).and_return([])
    end

    describe 'sets title' do
      it 'sets title correctly' do
        assign :entity, create(:entity_org, last_user_id: @user.id, name: 'mega corp')
        expect(view).to receive(:content_for).with(:page_title, 'mega corp')
        expect(view).to receive(:content_for).with(any_args).exactly(4).times
        render
      end
    end

    describe 'header' do
      context 'without any permissions' do
        before(:all) do
          DatabaseCleaner.start
          with_versioning_for(@user) do
            @e = create(:entity_org, name: 'mega corp', blurb: 'mega corp is having an existential crisis')
          end
        end

        after(:all) { DatabaseCleaner.clean }

        before do
          assign(:entity, @e)
          assign(:similar_entities, [])
          render
        end

        it 'has correct header' do
          expect(rendered).to have_css('#entity-name')
          expect(rendered).to have_css('#entity-name a', :count => 1)
          expect(rendered).to have_css('#entity-name', :text => "mega corp")
          expect(rendered).to have_css('#entity-blurb-wrapper', :text => "mega corp is having an existential crisis")
        end

        describe 'actions' do
          describe 'edited by section' do
            it 'links to recent user' do
              expect(rendered).to have_css('#entity-edited-history')
              expect(rendered).to have_css('#entity-edited-history strong a', :text => @user.username)
            end

            it 'display how long ago it was edited' do
              expect(rendered).to have_css('#entity-edited-history', :text => 'ago')
            end

            it 'links to history' do
              expect(rendered).to have_css('a[href="/org/' + @e.id.to_s + '-mega_corp/edit"]', :text => 'History')
            end
          end

          describe 'buttons' do
            it 'has action div' do
              expect(rendered).to have_css('#actions')
            end

            it 'has 3 links' do
              expect(rendered).to have_css('#actions a', :count => 3)
            end

            it 'has relationship link' do
              expect(rendered).to have_css('a', :text => 'add relationship')
            end

            it 'has edit link' do
              expect(rendered).to have_css('a', :text => 'edit')
            end

            it 'has flag link' do
              expect(rendered).to have_css('a', :text => 'flag')
            end

            it 'does not have remove button' do
              expect(rendered).not_to have_css('a', :text => 'remove')
            end

            it 'does not have match donations button' do
              expect(rendered).not_to have_css('a', :text => 'match donations')
            end

            it 'does not have add bulk button' do
              expect(rendered).not_to have_css('a', :text => 'add bulk')
            end

          end
        end
      end  # end of context without legacy permissions

      context 'with no special permissions' do
        before(:all) do
          DatabaseCleaner.start
          @user = create(:user)
          @e = create(:entity_org, last_user: @user, name: 'mega corp')
        end

        after(:all) { DatabaseCleaner.clean }

        before do
          assign(:entity, @e)
          # assign(:links, sorted_links(@e))
          assign(:current_user, @user)
          sign_in @user
          render
        end

        it 'has 5 links' do
          expect(rendered).to have_css('#actions a', :count => 5)
        end
      end

      describe 'with importer permission' do
        before(:all) do
          DatabaseCleaner.start
          @user = create(:user, abilities: UserAbilities.new(:edit, :bulk))
          @e = create(:entity_person, last_user: @user)
        end

        after(:all) { DatabaseCleaner.clean }

        before do
          assign(:entity, @e)
          assign(:current_user, @user)
          sign_in @user
          render
        end

        it 'has 7 links' do
          expect(rendered).to have_css('#actions a', :count => 7)
        end

        it 'renders match donations button' do
          expect(rendered).to have_css('a', :text => 'match donations')
        end

        it 'renders add bulk button' do
          expect(rendered).to have_css('a', :text => 'add bulk')
        end
      end

      describe 'tabs' do
        before(:all) do
          DatabaseCleaner.start
          @user = create(:user)
          @e = create(:entity_org, updated_at: Time.now, last_user: @user)
        end

        after(:all) { DatabaseCleaner.clean }

        before(:each) do
          assign(:entity, @e)
          assign(:current_user, @user)
          render
        end

        it 'has only one active tab' do
          expect(rendered).to have_css '.button-tabs span.active', :count => 1
        end

        it 'renders relationship tab' do
          expect(rendered).to have_css '.button-tabs span a', :text => 'Relationships', :count => 1
        end

        it 'Relationships is the active tab' do
          expect(rendered).to have_css '.button-tabs span.active a', :text => 'Relationships', :count => 1
          expect(rendered).not_to have_css '.button-tabs span.active a', :text => 'Interlocks'
        end

        it 'renders Interlocks tab' do
          expect(rendered).to have_css '.button-tabs span a', :text => 'Interlocks', :count => 1
        end

        it 'renders Giving tab' do
          expect(rendered).to have_css '.button-tabs span a', :text => 'Giving', :count => 1
        end

        it 'renders Political tab' do
          expect(rendered).to have_css '.button-tabs span a', :text => 'Political', :count => 1
        end

        it 'renders Data tab' do
          expect(rendered).to have_css '.button-tabs span a', :text => 'Data', :count => 1
        end
      end
    end
  end


end
