if ENV['CIRCLECI'] == 'true'
   warn "Skipping #{__FILE__} because it is flaky on Circleci."
else
  feature 'Featured list admin', :sphinx, type: :feature, js: true do
    let(:admin) { create_admin_user }
    let(:user) { create_basic_user }
    let(:nonfeatured_lists) { create_list(:list, 3, is_featured: false) }
    let(:featured_lists) { create_list(:list, 2, is_featured: true) }

    before { setup_sphinx }
    after { teardown_sphinx }

    context 'when logged in as an normal user' do
      before do
        featured_lists
        featured_lists.last.add_entity(create(:entity_org))
        nonfeatured_lists
        login_as user, scope: :user

        visit "/"

        find("#navmenu-dropdown-Explore").click

        within '.dropdown-menu.show' do
          click_on 'Lists'
        end
      end

      it 'shows featured lists by default' do
        expect(
          page.evaluate_script("document.getElementById('lists-only-featured').value")
        ).to eq 'on'

        featured_lists.each do |list|
          expect(page).to have_css("tr#list_#{list.id}", count: 1)
        end

        nonfeatured_lists.each do |list|
          expect(page).not_to have_css("tr#list_#{list.id}")
        end

        expect(page).not_to have_css('.star-button')
        expect(page).not_to have_css('.delete-button')
      end

      it 'can sort by entity count' do
        expect(page).to have_css '#lists i[data-column="entity_count"].bi-filter'
        find('#lists i[data-column="entity_count"]').click
        expect(page).to have_css '#lists i[data-column="entity_count"].bi-sort-down'
        expect(find_all('#lists tbody tr').first['id']).to eq "list_#{featured_lists.last.id}"
      end
    end

    context 'when logged in as an admin' do
      before do
        featured_lists
        nonfeatured_lists
        login_as admin, scope: :user
        visit "/lists?featured=true"
      end

      after do
        logout(:user)
      end

      scenario 'admin un-features a featured list' do
        within "tr\#list_#{featured_lists.last.id}" do
          find('.star-button').click
        end

        expect(page).to show_success('List was successfully updated.')
        expect(page).not_to have_css("tr#list_#{featured_lists.last.id}")
      end

      scenario 'admin features an unfeatured list' do
        expect(page).not_to have_css("tr#list_#{nonfeatured_lists.last.id}")

        find('#lists-only-featured').click
        find('#search-lists input[type="submit"]').click

        expect(page).to have_css("tr#list_#{nonfeatured_lists.last.id}")

        within "tr#list_#{nonfeatured_lists.last.id}" do
          find('.star-button').click
        end

        expect(page).to show_success('List was successfully updated.')
        expect(page).to have_css("tr#list_#{nonfeatured_lists.last.id}")

        find('#lists-only-featured').click
        find('#search-lists input[type="submit"]').click

        expect(
          page.evaluate_script("document.getElementById('lists-only-featured').value")
        ).to eq 'on'

        expect(page).to have_css("tr#list_#{nonfeatured_lists.last.id}")
      end

      scenario 'admin deletes a featured list' do
        within "tr#list_#{featured_lists.last.id}" do
          accept_confirm do
            find('.delete-button').click
          end
        end

        expect(page).to show_success('List was successfully destroyed.')
        expect(page).not_to have_css("tr#list_#{featured_lists.last.id}")
      end
    end
  end

end
