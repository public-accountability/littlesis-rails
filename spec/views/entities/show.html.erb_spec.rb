require 'rails_helper'

describe 'entities/show.html.erb' do
  before(:all) { DatabaseCleaner.start } 
  after(:all) { DatabaseCleaner.clean }

  before(:each) do
    allow(Entity).to receive(:search).and_return([])
  end

  def sorted_links(e)
    links = e.links.joins(:relationship).includes(:relationship, :related).order('relationship.end_date DESC')
    SortedLinks.new(links)
  end

  describe 'header' do    
    context 'without any permissions' do
      before(:all) do
        DatabaseCleaner.start
        @sf_user = create(:sf_guard_user, username: 'X')
        @user = create(:user, sf_guard_user_id: @sf_user.id)
        @e = create(:mega_corp_inc, last_user_id: @sf_user.id )
      end

      after(:all) { DatabaseCleaner.clean }

      before do
        assign(:entity, @e)
        # assign(:links, sorted_links(@e))
        assign(:similar_entities, [])
        render
      end

      it 'has correct header' do
        expect(rendered).to have_css('#entity-header')
        expect(rendered).to have_css('#entity-header a', :count => 1)
        expect(rendered).to have_css('#entity-name', :text => "mega corp INC")
        expect(rendered).to have_css('#entity-blurb', :text => "mega corp is having an existential crisis")
      end

      describe 'actions' do
        describe 'edited by section' do
          it 'links to recent user' do
            expect(rendered).to have_css('#entity-edited-history')
            expect(rendered).to have_css('#entity-edited-history strong a', :text => 'user')
          end

          it 'display how long ago it was edited' do 
            expect(rendered).to have_css('#entity-edited-history', :text => 'ago')
          end

          it 'links to history' do 
            expect(rendered).to have_css('a[href="/org/' + @e.id.to_s + '/mega_corp_INC/modifications"]', :text => 'History')
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

          it 'does not have refresh  button' do
            expect(rendered).not_to have_css('a', :text => 'refresh')
          end

        end
      end
    end  # end of context without legacy permissions

    context 'with deleter permission' do

      before(:all) do
        DatabaseCleaner.start
        @sf_user = create(:sf_guard_user)
        @user = create(:user, sf_guard_user_id: @sf_user.id)
        @e = create(:mega_corp_inc, last_user: @sf_user)
        SfGuardUserPermission.create!(user_id: @sf_user.id, permission_id: 5)
      end

      after(:all) { DatabaseCleaner.clean }

      before do
        assign(:entity, @e)
        # assign(:links, sorted_links(@e))
        assign(:current_user, @user)
        sign_in @user
        render
      end

      it 'has 4 links' do
        expect(rendered).to have_css('#actions a', :count => 4)
      end

      it 'renders remove button' do
        expect(rendered).to have_css('a', :text => 'remove')
      end
    end

    describe 'with importer permission' do
      before(:all) do 
        DatabaseCleaner.start
        @sf_guard_user = create(:sf_guard_user)
        @user = create(:user, sf_guard_user_id: @sf_guard_user.id)
        @e = create(:mega_corp_inc, last_user: @sf_guard_user)
        SfGuardUserPermission.create!(user_id: @sf_guard_user.id, permission_id: 8)
      end

      after(:all) { DatabaseCleaner.clean }

      before do
        assign(:entity, @e)
        assign(:current_user, @user)
        sign_in @user
        render
      end

      it 'has 5 links' do
        expect(rendered).to have_css('#actions a', :count => 5)
      end

      it 'renders match donations button' do
        expect(rendered).to have_css('a', :text => 'match donations')
      end

      it 'renders add bulk button' do
        expect(rendered).to have_css('a', :text => 'add bulk')
      end
    end

    describe 'with importer and deleter permission' do
      before do
        @sf_guard_user = create(:sf_guard_user, username: 'Y')
        @user = create(:user, sf_guard_user_id: @sf_guard_user.id)
        @e = create(:mega_corp_inc, last_user: @sf_guard_user)
        SfGuardUserPermission.create!(user_id: @sf_guard_user.id, permission_id: 5)
        SfGuardUserPermission.create!(user_id: @sf_guard_user.id, permission_id: 8)
        assign(:entity, @e)
        assign(:current_user, @user)
        sign_in @user
        render
      end

      it 'has 6 links' do
        expect(rendered).to have_css('#actions a', :count => 6)
      end
    end

    context 'as admin' do
      before do
        @sf_guard_user = create(:sf_guard_user)
        @user = create(:user, sf_guard_user_id: @sf_guard_user.id)
        @e = create(:mega_corp_inc, last_user: @sf_guard_user)
        SfGuardUserPermission.create!(user_id: @sf_guard_user.id, permission_id: 1)
        assign(:entity, @e)
        assign(:current_user, @user)
        sign_in @user
        render
      end

      it 'renders refresh button' do
        expect(rendered).to have_css('a', :text => 'refresh')
      end
    end

    describe 'tabs' do
      before(:all) do
        DatabaseCleaner.start
        @sf_guard_user = create(:sf_guard_user)
        @user = create(:user, sf_guard_user_id: @sf_guard_user.id)
        @e = create(:mega_corp_inc, updated_at: Time.now, last_user: @sf_guard_user)
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
