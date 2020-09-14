describe 'Permission Passes', type: :feature do
  let(:admin_user) { create_admin_user }
  let!(:old_pass) { create(:permission_pass, creator: admin_user, valid_from: 3.weeks.ago, valid_to: 2.weeks.ago) }
  let!(:pass) { create(:permission_pass, creator: admin_user) }

  before do
    login_as(admin_user, :scope => :user)
    visit '/admin'
  end

  after { logout(:admin_user) }

  scenario 'viewing all permission passes' do
    click_on 'permission passes'

    expect(page).to have_css('h1', text: 'Permission Passes')

    within '#permission-passes' do
      expect(page).to have_text(pass.event_name)
      expect(page).not_to have_text(old_pass.event_name)
    end
  end

  scenario 'creating a permission pass' do
    click_on 'permission passes'
    click_on 'New Permission Pass'

    expect(page).to have_css('h1', text: 'New Permission Pass')

    within '#permission-pass-form' do
      fill_in 'Event name', with: 'Some workshop'

      select_datetime 'Valid from', Time.current
      select_datetime 'Valid to', 2.hours.from_now

      %i[list bulk match].each do |ability|
        check ability
      end

      click_on 'Create Permission pass'
    end

    expect(page).to have_text('Permission pass was successfully created')
    expect(PermissionPass.last.abilities.to_a).to contain_exactly(:list, :bulk, :match)
  end

  context 'when a permission pass has been created' do
    let!(:pass) { create(:permission_pass, creator: admin_user, abilities: UserAbilities.new(:edit, :list, :bulk, :merge)) }

    scenario 'editing the pass abilities' do
      click_on 'permission passes'

      within "#permission-passes #pass_#{pass.id}" do
        click_on 'Edit'
      end

      within '#permission-pass-form' do
        uncheck :bulk
        uncheck :merge

        click_on 'Update Permission pass'
      end

      expect(page).to have_text('Permission pass was successfully updated')
      expect(PermissionPass.last.abilities.to_a).to contain_exactly(:edit, :list)
    end

    scenario 'choosing invalid dates' do
      click_on 'permission passes'

      within "#permission-passes #pass_#{pass.id}" do
        click_on 'Edit'
      end

      within '#permission-pass-form' do
        select_datetime 'Valid from', Time.current
        select_datetime 'Valid to', 2.years.from_now

        click_on 'Update Permission pass'
      end

      expect(page).to have_text('The maximum validity period is 1 week')

      within '#permission-pass-form' do
        select_datetime 'Valid from', Time.current
        select_datetime 'Valid to', 2.hours.ago

        click_on 'Update Permission pass'
      end

      expect(page).to have_text('Valid to must be after the valid from date')
    end
  end

  context 'when user is given permission pass link' do
    let(:user) { create(:user, abilities: UserAbilities.new(:edit)) }
    let!(:pass) { create(:permission_pass, creator: admin_user, abilities: UserAbilities.new(:edit, :list, :bulk, :merge)) }

    before do
      login_as(user, scope: :user)
    end

    scenario 'user visits link and is granted abilities' do
      visit permission_pass_apply_path(pass)

      expect(page).to have_text('Permission pass abilities applied')
      expect(user.abilities.to_a).to contain_exactly(:edit, :list, :bulk, :merge)
    end
  end
end
