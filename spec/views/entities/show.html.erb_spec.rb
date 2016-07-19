require 'rails_helper' 

describe 'entities/show.html.erb' do
  describe 'layout' do    
    context 'without any permissions' do 
      before do
        @user = create(:user)
        @e = create(:mega_corp_inc)
        assign(:entity, @e)
        assign(:last_user, @user) 
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
            expect(rendered).to have_css('#entity-actions')
          end

          it 'has 3 links' do 
            expect(rendered).to have_css('#entity-actions a', :count => 3)
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

      before do
        @e = create(:mega_corp_inc)
        @user = create(:user)
        @sf_guard_user = create(:sf_user)
        SfGuardUserPermission.create!(user_id: @sf_guard_user.id, permission_id: 5)
        assign(:entity, @e)
        assign(:last_user, @user) 
        assign(:current_user, User.find(@user.id))
        sign_in @user
        render
      end
      
      it 'has 4 links' do
        expect(rendered).to have_css('#entity-actions a', :count => 4)
      end
      
      it 'render remove button' do
        expect(rendered).to have_css('a', :text => 'remove')
      end
    end
  
  end
end

