describe "Entity Page", :network_analysis_helper, :pagination_helper, type: :feature do
  include EntitiesHelper

  let(:user) { create_basic_user }
  let(:person) do
    with_versioning_for(user) do
      create(:entity_person, blurb: Faker::Lorem.sentence)
    end
  end
  let(:org) do
    with_versioning_for(user) do
      create(:entity_org)
    end
  end
  let(:visit_page) { proc { visit concretize_entity_path(person) } }

  before do
    allow(Entity).to receive(:search).and_return([])
  end

  describe 'routes' do
    def should_visit_entity_page(url)
      visit url
      expect(page.status_code).to eq 200
      expect(page).to have_current_path url
      expect(page).to have_selector '#entity-page-container'
    end

    it 'accepts person a valid entities slug' do
      should_visit_entity_page "/person/#{person.to_param}"
      should_visit_entity_page "/person/#{person.to_param}/interlocks"
    end

    it 'accepts org as an valid entities slug' do
      should_visit_entity_page "/org/#{org.to_param}"
      should_visit_entity_page "/org/#{org.to_param}/interlocks"
    end

    it 'rejects routes with extra prefixes' do
      visit "/extra/prefix/org/#{org.to_param}"
      expect(page.status_code).to eq 404
    end

    it 'redirects legacy symfony-style urls to canonical entity urls' do
      visit "/org/#{org.id}/#{org.name}"
      expect(page).to have_current_path "http://test.host/org/#{org.id}-org"

      visit "/org/#{org.id}/#{org.name}/interlocks"
      expect(page).to have_current_path "http://test.host/org/#{org.id}-org"
    end
  end

  describe 'redirecting merged entities' do
    def should_redirect(src_url, dst_url)
      visit src_url
      expect(page.status_code).to eq 200
      expect(page).to have_current_path dst_url
      expect(page).to have_selector '#entity-name'
    end

    %i[alice bob cassie].each do |person|
      let!(person) { create(:entity_person) }
    end

    context "when alice has been merged into bob" do
      before { EntityMerger.new(source: alice, dest: bob).merge! }

      it "redirects from alice's profile page to bob's profile page" do
        should_redirect(concretize_entity_path(alice), concretize_entity_path(bob))
      end

      %i[interlocks giving].each do |tab|
        it "redirects from alice's #{tab} tab to bob's #{tab} tab" do
          should_redirect(tab_person_path(alice, tab: tab),
                          tab_person_path(bob, tab: tab))
        end
      end
    end

    context "when alice has been merged into bob who has been merged into cassie" do
      before do
        EntityMerger.new(source: alice, dest: bob).merge!
        EntityMerger.new(source: bob, dest: cassie).merge!
      end

      it "redirects from alice's profile page to cassie's profile page" do
        should_redirect(concretize_entity_path(alice), concretize_entity_path(cassie))
      end

      %i[interlocks giving].each do |tab|
        it "redirects from alice's #{tab} tab to cassie's #{tab} tab" do
          should_redirect(concretize_tab_entity_path(alice, tab: tab),
                          concretize_tab_entity_path(cassie, tab: tab))
        end
      end
    end

    context "when alice has been merged into bob, bob is deleted" do

      before do
        EntityMerger.new(source: alice, dest: bob).merge!
        bob.soft_delete
      end

      it "renders 'not found' when trying to visit alice's page" do
        visit concretize_entity_path(alice)
        expect(page.status_code).to eq 404
        expect(page).to have_text "Page Not Found"
      end

      %i[interlocks giving].each do |tab|
        it "renders 'not found' when trying to visit alice's #{tab} tab" do
          visit tab_entity_path(alice, tab: tab)
          expect(page.status_code).to eq 404
          expect(page).to have_text "Page Not Found"
        end
      end
    end

    context "when alice has been merged into bob, bob into cassie, cassie is deleted" do

      before do
        EntityMerger.new(source: alice, dest: bob).merge!
        EntityMerger.new(source: bob, dest: cassie).merge!
        cassie.soft_delete
      end

      it "renders 'not found' when trying to visit alice's page" do
        visit concretize_entity_path(alice)
        expect(page.status_code).to eq 404
        expect(page).to have_text "Page Not Found"
      end
    end
  end

  describe "header" do
    before { visit_page.call }

    context 'with an anonymous user' do
      it "shows the entity's name" do
        expect(page.find("#entity-name")).to have_text person.name
      end

      it "shows a description of the entity" do
        expect(page.find("#entity-blurb-text")).to have_text person.blurb
      end

      it 'does not link to editable blurb' do
        expect(page).not_to have_selector '#editable-blurb'
      end

      it "does not have action buttons" do
        expect(page).not_to have_selector '.action-button'
      end

      it "shows updated at" do
        expect(page.find('#entity-edited-history')).not_to have_selector 'a'
        expect(page.find('#entity-edited-history')).to have_text 'Updated'
      end
    end

    context 'when the user is signed in' do
      let(:user) { create_basic_user }

      before { login_as(user, scope: :user) }

      after { logout(user) }

      it 'has editable blurb' do
        expect(page).not_to have_selector '#editable-blurb'
      end

      it "shows link to edit history" do
        expect(page.find('#entity-edited-history a')[:href]).to eq concretize_history_entity_path(person)
        expect(page.find('#entity-edited-history').text).to include 'Updated'
      end

      it 'has action buttons' do
        page_has_selector ".action-button", count: 3
      end
    end
  end # end describe header

  describe "summary field" do
    before { visit_page.call }

    it "hides the summary field if user has no summary" do
      expect(page).not_to have_selector("#entity_summary")
    end

    context "with an entity that has a summary" do
      let(:person) do
        create(:entity_person, last_user_id: user.id, summary: "foobar")
      end

      it "shows the summary" do
        expect(page.find("#entity-summary")).to have_text person.summary
      end
    end

    context "with an entity that has a summary longer than limit" do
      let(:person) do
        create(:entity_person,
               last_user_id: user.id,
               summary: "a" * (Entity::EXCERPT_SIZE + 1))
      end

      it "excerpts the summary" do
        expect(page.find("#entity-summary")).to have_text "a" * Entity::EXCERPT_SIZE
      end

      it "allows user to hide and show longer version (HACK)" do
        expect(page).to have_selector ".summary-show-more"
        expect(page).to have_selector ".summary-show-less", visible: :hidden
      end
    end
  end

  describe "sidebar" do
    subject { page.find("#profile-page-sidebar") }

    let(:tags) { Array.new(2) { create(:tag) } }

    let(:create_tags) { proc { tags.each { |t| person.add_tag(t.id) } } }

    before do
      allow(Entity).to receive(:search).and_return([build(:entity_person)])
    end

    context 'with an anonymous user' do
      context 'with similar entities' do
        before do
          allow(Entity).to receive(:search).and_return([build(:entity_person)])
          visit_page.call
        end

        it { is_expected.to have_selector "#sidebar-similar-entities-container" }
        it { is_expected.to have_text 'Similar Entities' }
        it { is_expected.not_to have_selector 'a#begin-merging-process-link' }
      end

      context 'without similar entities' do
        before do
          allow(Entity).to receive(:search).and_return([])
          visit_page.call
        end

        it { is_expected.not_to have_selector "#sidebar-similar-entities-container" }
        it { is_expected.not_to have_text 'Similar Entities' }
      end

      context 'without tags' do
        before do
          visit_page.call
        end

        it 'has sections' do
          subject_has_selectors "#sidebar-image-container", "#sidebar-basic-info-container",
                                "#sidebar-lists-container", "#sidebar-source-links"
        end

        it { is_expected.not_to have_selector 'a.tag' }
        it { is_expected.not_to have_selector "#tags-edit-button" }
        it { is_expected.not_to have_selector '#sidebar-external-links-container' }
      end

      context 'with tags' do
        before do
          create_tags.call
          visit_page.call
        end

        it { is_expected.to have_selector 'a.tag', count: 2 }
        it { is_expected.not_to have_selector "#tags-edit-button" }
      end

      context 'with external links' do
        let(:link_id) { Faker::Number.unique.number(digits: 6).to_s }

        before do
          ExternalLink.create!(link_type: 'sec', entity_id: person.id, link_id: link_id)
          visit_page.call
        end

        scenario 'viewing external links section' do
          expect(find('#sidebar-external-links-container').text).to include 'External Links'
          page_has_selector '#sidebar-external-links-container a', count: 1
        end
      end

      context 'with network maps' do
        let!(:featured_map) { create(:network_map, is_featured: true, user_id: user.id) }
        let!(:regular_map) { create(:network_map, user_id: user.id) }
        let!(:private_map) { create(:network_map, is_private: true, user_id: user.id) }
        let(:maps) { [featured_map, regular_map, private_map] }

        before do
          map_collection = person.network_map_collection
          maps.each { |m| map_collection.add(m.id) }
          map_collection.save
          visit_page.call
        end

        it 'has a network maps section' do
          expect(find('#sidebar-maps-container').text).to include 'Network Maps'
        end

        it 'only shows featured maps' do
          page_has_selector '#sidebar-maps-container li a', count: 1
          expect(find('#sidebar-maps-container ul > li:nth-child(1) > a')['href'])
            .to eql map_path(featured_map)
        end

        it "doesn't show private maps" do
          expect(all('#sidebar-maps-container ul a').map { |e| e['href'] })
            .not_to include map_path(private_map)
        end
      end

      context 'with a featured resource' do
        let(:url) { Faker::Internet.url }

        before do
          person.featured_resources.create!(title: 'this is a title', url: url)
          visit_page.call
        end

        it 'has link to the featured resource' do
          page_has_selector '#sidebar-featured-resource-container', count: 1
          expect(page.find('#sidebar-featured-resource-container a')[:href]).to eq(url)
        end
      end
    end

    describe 'cmp data partner' do
      let(:user) { create_admin_user }

      let(:entity_in_strata) do
        create(:entity_person).tap do |e|
          CmpEntity.create!(entity: e, strata: 1, entity_type: :person)
        end
      end

      let(:entity_not_in_strata) do
        create(:entity_person).tap do |e|
          CmpEntity.create!(entity: e, strata: nil, entity_type: :person)
        end
      end

      before { login_as(user, scope: :user) }

      after { logout(user) }

      describe 'viewing cmp entity page (in strata)' do
        before { visit concretize_entity_path(entity_in_strata) }

        specify { page_has_selector '#sidebar-data-partner-container' }
      end

      describe 'viewing cmp entity page (NOT in strata)' do
        before { visit concretize_entity_path(entity_not_in_strata) }

        specify { page_has_no_selector '#sidebar-data-partner-container' }
      end
    end

    describe "when logged in" do
      let(:user) { create_basic_user }

      before { login_as(user, scope: :user) }

      after { logout(user) }

      context 'with a regular user' do
        context 'without tags' do
          before { visit_page.call; }

          it { is_expected.not_to have_selector 'a.tag' }
          it { is_expected.to have_selector "#tags-edit-button" }
        end

        context "when person has tags" do
          before do
            create_tags.call
            visit_page.call
          end

          it { is_expected.to have_selector "#tags-edit-button" }
          it { is_expected.to have_selector 'a.tag', count: 2 }
        end
      end

      context "with an admin user" do
        let(:user) { create_admin_user }

        context 'without tags' do
          before { visit_page.call; }

          it { is_expected.not_to have_selector 'a.tag' }
          it { is_expected.to have_selector "#tags-edit-button" }
        end

        context "with similar entities" do
          before do
            allow(Entity).to receive(:search).and_return([build(:entity_person)])
            visit_page.call
          end

          it { is_expected.to have_selector "#sidebar-similar-entities-container" }
          it { is_expected.to have_selector 'a#begin-merging-process-link' }
        end

        context "when person has tags" do
          before do
            create_tags.call
            visit_page.call
          end

          it { is_expected.to have_selector "#tags-edit-button" }
          it { is_expected.to have_selector 'a.tag', count: 2 }
        end
      end
    end
  end # end describe sidebar

  describe "navigation tabs" do
    before { visit_page.call }

    let(:subpage_links) do
      [{ text: 'Relationships',  path: concretize_entity_path(person) },
       { text: 'Interlocks',     path: concretize_tab_entity_path(person, tab: :interlocks) },
       { text: 'Giving',         path: concretize_tab_entity_path(person, tab: :giving) },
       # { text: 'Political',      path: concretize_political_entity_path(person) },
       { text: 'Data',           path: concretize_datatable_entity_path(person) }]
    end

    it "has tabs for every subpage" do
      subpage_links.each do |link|
        expect(page).to have_link(link[:text], href: link[:path])
      end
    end

    it "defaults to relationships tab" do
      expect(page).to have_current_path concretize_entity_path(person)
      expect(page.find('div.button-tabs span.active'))
        .to have_link('Relationships')
    end
  end

  describe "Relationship Tab - with category Membership" do
    let(:org_with_members) { create(:entity_org) }
    let(:org_with_memberships) { create(:entity_org) }

    before do
      create(:generic_relationship, entity: org_with_members, related: create(:entity_person))
      create(:membership_relationship, entity: org_with_memberships, related: org_with_members)
    end

    context 'when on an entity page with memberships' do
      before { visit concretize_entity_path(org_with_memberships, relationships: 'memberships') }

      it 'show title Memberships' do
        # expect(page.find('#relationship_tabs_content')).to have_text 'Memberships', count: 1
        page_has_selector 'div.subsection', text: 'Memberships', count: 1
      end
    end

    context 'when on an entity page with members' do
      before { visit concretize_entity_path(org_with_members, relationships: 'members') }

      it 'show title Memberships' do
        expect(page.find('#relationship_tabs_content')).to have_text 'Members'
      end
    end
  end

  describe "relationships tab" do
    before { visit concretize_entity_path(person) }

    context 'with no relationships' do
      it 'shows stub message' do
        successfully_visits_page concretize_entity_path(person)
        page_has_selector '#entity-without-relationships-message'
        expect(find('#entity-without-relationships-message p a')[:href])
          .to eql concretize_add_relationship_entity_path(person)
      end
    end

    context 'with two relationships: position and generic' do
      let(:entity) { create(:entity_person) }

      before do
        Relationship.create!(category_id: 1, entity: entity, related: create(:entity_org))
        Relationship.create!(category_id: 12, entity: entity, related: create(:entity_org))
        visit concretize_entity_path(entity)
      end

      scenario 'displays two relationships' do
        successfully_visits_page concretize_entity_path(entity)
        expect(page).not_to have_selector '#entity-without-relationships-message'
        page_has_selector 'div.relationship-section', count: 2
        page_has_selector 'div.subsection', text: 'Positions'
        page_has_selector 'div.subsection', text: 'Other Affiliations'
      end
    end
  end

  describe "interlocks tab" do
    context "with a person" do
      let(:people) { create_list(:entity_person, 4, :with_last_user_id) }
      let(:orgs) { create_list(:entity_org, 3) }
      let(:root_entity) { people.first }

      before do
        interlock_people_via_orgs(people, orgs)
        visit tab_entity_path(root_entity, tab: :interlocks)
      end

      describe "table layout" do
        it "shows a header and subheader" do
          expect(page.find("#entity-connections-title"))
            .to have_text "People in Common Orgs"
          expect(page.find("#entity-connections-subtitle"))
            .to have_text "same orgs as #{root_entity.name}"
        end

        it "shows a table of connected entites" do
          expect(page.find("#entity-connections-table tbody")).to have_selector "tr", count: 3
        end

        it "shows a table header for connected entities" do
          expect(page.find("#connected-entity-header")).to have_text "Person"
        end

        it "shows a table header for connecting entities" do
          expect(page.find("#connecting-entity-header")).to have_text "Common Orgs"
        end

        describe "first row" do
          subject(:row) { page.all("#entity-connections-table tbody tr").first }

          it "displays the most-interlocked person's name as link" do
            expect(row.find('.connected-entity-cell'))
              .to have_link(person.name, href: concretize_entity_path(people[3]))
          end

          it "displays interlocking orgs' names as links in same row as interlocked people" do
            orgs.each do |org|
              expect(row.find('.connecting-entities-cell'))
                .to have_link(org.name, href: concretize_entity_path(org))
            end
          end
        end
      end

      describe "pagination" do
        context "less than #{Entity::PER_PAGE} interlocks" do
          it "does not show a pagination bar" do
            expect(page.find("#entity-connections-pagination"))
              .not_to have_selector(".pagination")
          end
        end

        context "more than #{Entity::PER_PAGE} interlocks" do
          stub_page_limit(Entity)

          let(:people) do
            Array.new(Entity::PER_PAGE + 2) do
              create(:entity_person, last_user_id: User.system_user_id)
            end
          end

          it "shows a pagination bar" do
            expect(page.find("#entity-connections-pagination"))
              .to have_selector(".pagination")
          end

          it "only shows #{Entity::PER_PAGE} rows" do
            expect(page.find("#entity-connections-table tbody"))
              .to have_selector "tr", count: Entity::PER_PAGE
          end
        end
      end
    end

    context "with an organization" do
      let(:orgs) { Array.new(4) { create(:entity_org, :with_last_user_id) } }
      let(:people) { Array.new(3) { create(:entity_person) } }
      let(:root_entity) { orgs.first }

      before do
        interlock_orgs_via_people(orgs, people)
        visit tab_entity_path(root_entity, tab: :interlocks)
      end

      it "shows a header and subheader" do
        expect(page.find("#entity-connections-title"))
          .to have_text "Orgs with Common People"
        expect(page.find("#entity-connections-subtitle"))
          .to have_text "of #{org.name} also have"
      end

      it "shows a table of connected entites" do
        expect(page.find("#entity-connections-table tbody")).to have_selector "tr", count: 3
      end

      it "shows a table header for connected entities" do
        expect(page.find("#connected-entity-header")).to have_text "Org"
      end

      it "shows a table header for connecting entities" do
        expect(page.find("#connecting-entity-header")).to have_text "Common "
      end

      describe "first row" do
        subject(:row) { page.all("#entity-connections-table tbody tr").first }

        it "displays the most-interlocked org's name as link" do
          expect(row.find('.connected-entity-cell'))
            .to have_link(org.name, href: concretize_entity_path(orgs[3]))
        end

        it "displays interlocking peoples' names as links in same row as interlocked org" do
          people.each do |person|
            expect(row.find('.connecting-entities-cell'))
              .to have_link(person.name, href: concretize_entity_path(person))
          end
        end
      end
    end
  end

  describe "giving tab" do
    describe "for a person" do
      let(:donors) { create_list(:entity_person, 4, :with_last_user_id) }
      let(:recipients) { create_list(%i[entity_org entity_person].sample, 3) }
      let(:root_entity) { donors.first }
      let(:setup_donations) { proc { create_donations_from(donors, recipients) } }

      before do
        create_donations_from(donors, recipients)
        visit tab_entity_path(root_entity, tab: :giving)
      end

      it 'shows correct page' do
        expect(page).to have_current_path tab_entity_path(root_entity, tab: :giving)
      end

      it "shows a header and subheader" do
        expect(page.find("#entity-connections-title"))
          .to have_text "Donors to Common Recipients"
        expect(page.find("#entity-connections-subtitle"))
          .to have_text "from #{root_entity.name} also received"
      end

      it "has a table of connected entities" do
        expect(page).to have_css('#entity-connections-table tbody tr', count: 3)
      end

      it "shows a table header for connected entities" do
        expect(page.find("#connected-entity-header")).to have_text "Donor"
      end

      it "shows a table header for connecting entities" do
        expect(page.find("#connecting-entity-header")).to have_text "Common Recipients"
      end

      describe "first row" do
        subject(:row) { page.all("#entity-connections-table tbody tr").first }

        it "displays the most-connected donor's name as link" do
          expect(row.find('.connected-entity-cell'))
            .to have_link(root_entity.name, href: concretize_entity_path(donors[3]))
        end

        it "displays connecting recipients' names as links in same row as connected donors" do
          recipients.each do |r|
            expect(page)
              .to have_css(".connecting-entities-cell a[href='#{concretize_entity_path(r)}']", text: r.name)
          end
        end
      end
    end

    describe "for an org" do
      let(:org) { create(:entity_org, :with_last_user_id) }
      let(:donors) { create_list(:entity_person, 3) }
      let(:recipients) { create_list(:entity_org, 4) }
      let(:root_entity) { org }

      before do
        donors.each { |d| create(:position_relationship, entity: d, related: org) }
        create_donations_to(recipients, donors)

        visit tab_entity_path(root_entity, tab: :giving)
      end

      it 'shows correct page' do
        expect(page).to have_current_path tab_entity_path(org, tab: :giving)
      end

      it "shows a header and subheader" do
        expect(page.find("#entity-connections-title"))
          .to have_text "People Have Given To"
        expect(page.find("#entity-connections-subtitle"))
          .to have_text "People with positions in #{root_entity.name} have made donations to"
      end

      it "has a table of connected entites" do
        expect(org.relationships.count).to eq 3
        expect(page.find("#entity-connections-table tbody")).to have_selector "tr", count: 3
      end

      it "shows a table header for (connected) recipients" do
        expect(page.find("#connected-entity-header")).to have_text "Recipient"
      end

      it "shows a table header for donation amount" do
        expect(page.find("#connection-stat-header")).to have_text "Total"
      end

      it "shows a table header for (connecting) donors" do
        expect(page.find("#connecting-entity-header")).to have_text "Donors"
      end

      describe "first row" do
        subject { page.all("#entity-connections-table tbody tr").first }

        it "displays the most-donated-to recipient's name as link" do
          expect(page).to have_css('.connected-entity-cell a', text: root_entity.name)
        end

        it "displays connecting donors' names as links" do
          donors.each do |d|
            expect(page)
              .to have_css(".connecting-entities-cell a[href='#{concretize_entity_path(d)}']", text: d.name)
          end
        end

        it "displays the sum of donations given by connecting donors" do
          expect(page).to have_css('.connection-stat-cell', text: ActiveSupport::NumberHelper.number_to_currency(900, precision: 0))
        end
      end
    end
  end
end
