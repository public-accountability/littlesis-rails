# rubocop:disable Style/StringLiterals

describe "Entity Page", :network_analysis_helper, :pagination_helper, type: :feature do
  include EntitiesHelper

  let(:user) { create_basic_user }
  let(:person) do
    with_versioning_for(user) do
      create(:entity_person)
    end
  end
  let(:org) do
    with_versioning_for(user) do
      create(:entity_org)
    end
  end
  let(:visit_page) { proc { visit concretize_entity_path(person) } }
  before(:each) do
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

      EntitiesController::TABS.each do |tab|
        it "redirects from alice's #{tab} tab to bob's #{tab} tab" do
          should_redirect(send("#{tab}_entity_path", alice),
                          send("#{tab}_entity_path", bob))
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

      EntitiesController::TABS.each do |tab|
        it "redirects from alice's #{tab} tab to cassie's #{tab} tab" do
          should_redirect(send("#{tab}_entity_path", alice),
                          send("#{tab}_entity_path", cassie))
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

      EntitiesController::TABS.each do |tab|
        it "renders 'not found' when trying to visit alice's #{tab} tab" do
          visit send("#{tab}_entity_path", alice)
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

    context 'anon user' do

      it "shows the entity's name" do
        expect(page.find("#entity-name")).to have_text person.name
      end

      it "shows a description of the entity" do
        expect(page.find("#entity-blurb-text")).to have_text person.blurb
      end

      it 'does not link to edit blurb'

      it "shows action buttons" do
        page_has_selector ".action-button", count: 3
      end

      it "shows an edit history" do
        expect(page.find('#entity-edited-history strong a')[:href]).to eql "/users/#{user.username}"
        expect(page.find('#entity-edited-history')).to have_text "ago"
      end
    end

    context 'user is signed in' do
      let(:user) { create_basic_user }
      before { login_as(user, scope: :user) }
      after { logout(user) }

      it 'has editable blurb'
    end
  end # end describe header

  describe "summary field" do
    before { visit_page.call }

    it "hides the summary field if user has no summary" do
      expect(page).not_to have_selector("#entity_summary")
    end

    context "entity has summary" do
      let(:person) do
        create(:entity_person, last_user_id: user.id, summary: "foobar")
      end

      it "shows the summary" do
        expect(page.find("#entity-summary")).to have_text person.summary
      end
    end

    context "entity has summary longer than limit" do
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
        expect(page).to have_selector ".summary-show-less", visible: false
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

    context 'anon user' do
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
        it { is_expected.not_to have_selector 'script#edit-tags-javascript' }
        it { is_expected.not_to have_selector '#sidebar-external-links-container' }
      end

      context 'with tags' do
        before { create_tags.call; visit_page.call; }
        it { is_expected.to have_selector 'a.tag', count: 2 }
        it { is_expected.not_to have_selector "#tags-edit-button" }
        it { is_expected.not_to have_selector 'script#edit-tags-javascript' }
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

        scenario 'viewing network maps section' do
          expect(find('#sidebar-maps-container').text).to include 'Network Maps'
          page_has_selector '#sidebar-maps-container li a', count: 2
          # first link is the featured map
          expect(find('#sidebar-maps-container ul > li:nth-child(1) > a')['href'])
            .to eql map_path(featured_map)
          # does not have private map
          expect(all('#sidebar-maps-container ul a').map { |e| e['href'] })
            .not_to include map_path(private_map)
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

      context 'regular user' do
        context 'without tags' do
          before { visit_page.call; }
          it { is_expected.not_to have_selector 'a.tag' }
          it { is_expected.to have_selector "#tags-edit-button" }
          it { is_expected.to have_selector 'script#edit-tags-javascript' }
        end
        context "when person has tags" do
          before { create_tags.call; visit_page.call; }
          it { is_expected.to have_selector "#tags-edit-button" }
          it { is_expected.to have_selector 'a.tag', count: 2 }
          it { is_expected.to have_selector 'script#edit-tags-javascript' }
        end
      end

      context "admin user" do
        let(:user) { create_admin_user }

        context 'without tags' do
          before { visit_page.call; }
          it { is_expected.not_to have_selector 'a.tag' }
          it { is_expected.to have_selector "#tags-edit-button" }
          it { is_expected.to have_selector 'script#edit-tags-javascript' }
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
          before { create_tags.call; visit_page.call; }
          it { is_expected.to have_selector "#tags-edit-button" }
          it { is_expected.to have_selector 'a.tag', count: 2 }
          it { is_expected.to have_selector 'script#edit-tags-javascript' }
        end
      end
    end
  end # end describe sidebar

  describe "navigation tabs" do
    before { visit_page.call }
    let(:subpage_links) do
      [{ text: 'Relationships',  path: concretize_entity_path(person) },
       { text: 'Interlocks',     path: concretize_interlocks_entity_path(person) },
       { text: 'Giving',         path: concretize_giving_entity_path(person) },
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

    context 'on entity page with memberships' do
      before { visit concretize_entity_path(org_with_memberships, relationships: 'memberships') }

      it 'show title Memberships' do
        # expect(page.find('#relationship_tabs_content')).to have_text 'Memberships', count: 1
        page_has_selector 'div.subsection', text: 'Memberships', count: 1
      end
    end

    context 'on entity page with members' do
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
    let(:interlocks) {}
    let(:root_entity) {}

    before do
      interlocks
      visit interlocks_entity_path(root_entity)
    end

    context "for a person" do
      let(:people) { Array.new(4) { create(:entity_person, :with_last_user_id) } }
      let(:orgs) { Array.new(3) { create(:entity_org) } }
      let(:root_entity) { people.first }
      let(:interlocks) { interlock_people_via_orgs(people, orgs)}

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
          subject { page.all("#entity-connections-table tbody tr").first }

          it "displays the most-interlocked person's name as link" do
            expect(subject.find('.connected-entity-cell'))
              .to have_link(person.name, href: concretize_entity_path(people[3]))
          end

          it "displays interlocking orgs' names as links in same row as interlocked people" do
            orgs.each do |org|
              expect(subject.find('.connecting-entities-cell'))
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
              create(:entity_person, last_user_id: APP_CONFIG['system_user_id'])
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

    context "for an organization" do
      let(:orgs) { Array.new(4) { create(:entity_org, :with_last_user_id) } }
      let(:people) { Array.new(3) { create(:entity_person) } }
      let(:root_entity) { orgs.first }
      let(:interlocks) { interlock_orgs_via_people(orgs, people) }

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
        subject { page.all("#entity-connections-table tbody tr").first }

        it "displays the most-interlocked org's name as link" do
          expect(subject.find('.connected-entity-cell'))
            .to have_link(org.name, href: concretize_entity_path(orgs[3]))
        end

        it "displays interlocking peoples' names as links in same row as interlocked org" do
          people.each do |person|
            expect(subject.find('.connecting-entities-cell'))
              .to have_link(person.name, href: concretize_entity_path(person))
          end
        end
      end
    end
  end

  describe "giving tab" do
    let(:setup_donations) { proc {} }
    let(:root_entity) {}

    before do
      setup_donations.call
      visit giving_entity_path(root_entity)
    end

    describe "for a person" do
      let(:donors) { Array.new(4) { create(:entity_person, :with_last_user_id) } }
      let(:recipients) { Array.new(3) { create(%i[entity_org entity_person].sample) } }
      let(:setup_donations) { proc { create_donations_from(donors, recipients) } }
      let(:root_entity) { donors.first }

      it "shows a header and subheader" do
        expect(page.find("#entity-connections-title"))
          .to have_text "Donors to Common Recipients"
        expect(page.find("#entity-connections-subtitle"))
          .to have_text "from #{root_entity.name} also received"
      end

      it "has a table of connected entites" do
        expect(page.find("#entity-connections-table tbody")).to have_selector "tr", count: 3
      end

      it "shows a table header for connected entities" do
        expect(page.find("#connected-entity-header")).to have_text "Donor"
      end

      it "shows a table header for connecting entities" do
        expect(page.find("#connecting-entity-header")).to have_text "Common Recipients"
      end

      describe "first row" do
        subject { page.all("#entity-connections-table tbody tr").first }

        it "displays the most-connected donor's name as link" do
          expect(subject.find('.connected-entity-cell'))
            .to have_link(root_entity.name, href: concretize_entity_path(donors[3]))
        end

        it "displays connecting recipients' names as links in same row as connected donors" do
          recipients.each do |r|
            expect(subject.find('.connecting-entities-cell'))
              .to have_link(r.name, href: concretize_entity_path(r))
          end
        end
      end
    end

    describe "for an org" do
      let(:org) { create(:entity_org, :with_last_user_id) }
      let(:donors) { Array.new(3) { |n| create(:entity_person) } }
      let(:recipients) do
        Array.new(4) { |n| create(:entity_org, name: "org-#{n}") }
      end
      let(:root_entity){ org }

      let(:setup_donations) do
        proc do
          donors.each_with_index { |d| create(:position_relationship, entity: d, related: org) }
          create_donations_to(recipients, donors)
        end
      end

      it 'shows correct page' do
        expect(page.current_path).to eql giving_entity_path(org)
      end

      it "shows a header and subheader" do
        expect(page.find("#entity-connections-title"))
          .to have_text "People Have Given To"
        expect(page.find("#entity-connections-subtitle"))
          .to have_text "People with positions in #{root_entity.name} have made donations to"
      end

      it "has a table of connected entites" do
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
          expect(subject.find('.connected-entity-cell'))
            .to have_link(root_entity.name, href: concretize_entity_path(recipients[3]))
        end

        it "displays connecting donors' names as links" do
          donors.each do |d|
            expect(subject.find('.connecting-entities-cell'))
              .to have_link(d.name, href: concretize_entity_path(d))
          end
        end

        it "displays the sum of donations given by connecting donors" do
          expect(subject.find('.connection-stat-cell'))
            .to have_text ActiveSupport::NumberHelper.number_to_currency(900, precision: 0)
        end
      end
    end
  end
end

# rubocop:enable Style/StringLiterals
