require 'rails_helper'

describe "Entity Page", :network_analysis_helper, :pagination_helper, type: :feature do
  # TODO: include Routes (which will force internal handling of /people/..., /orgs/... routes)
  let(:user) { create_basic_user }
  let(:person) { create(:entity_person, last_user_id: user.sf_guard_user.id) }
  let(:org) { create(:entity_org, last_user_id: user.sf_guard_user.id) }

  before do
    visit entity_path(person)
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

    it 'rewrites legacy symfony-style urls to rails urls' do
      should_visit_entity_page "/org/#{org.id}/#{org.name}"
      should_visit_entity_page "/org/#{org.id}/#{org.name}/interlocks"
    end
  end

  describe "header" do
    it "shows the entity's name" do
      expect(page.find("#entity-name")).to have_text person.name
    end

    it "shows a description of the entity" do
      expect(page.find("#entity-blurb")).to have_text person.blurb
    end

    it "shows action buttons" do
      page_has_selector ".action-button", count: 3
    end

    it "shows social media buttons" do
      page_has_selectors ".fb-share-button", ".twitter-share-button"
    end

    # context 'user is signed in' do
    #   it 'show advanced user action buttons'
    # end

    it "shows an edit history" do
      expect(page.find('#entity-edited-history')).to have_text "ago"
    end
  end

  describe "summary field" do
    it "hides the summary field if user has no summary" do
      expect(page).not_to have_selector("#entity_summary")
    end

    context "entity has summary" do
      let(:person) do
        create(:entity_person, last_user_id: user.sf_guard_user.id, summary: "foobar")
      end

      it "shows the summary" do
        expect(page.find("#entity-summary")).to have_text person.summary
      end
    end

    context "entity has summary longer than limit" do
      let(:person) do
        create(:entity_person,
               last_user_id: user.sf_guard_user.id,
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

    #TODO(ag|Wed 27 Sep 2017): flesh these out!

    subject { page.find("#profile-page-sidebar")}

    it 'has sections' do
      subject_has_selectors "#sidebar-image-container",
                            "#sidebar-basic-info-container",
                            "#sidebar-lists-container",
                            "#sidebar-source-links"
    end

    it "does not show a tag edit button for anon users" do
      expect(subject).not_to have_selector "#tags-edit-button"
    end

    describe "when logged in" do
      let(:user) { create_basic_user }
      before { login_as(user, scope: :user) }
      after { logout(user) }

      # TODO(ag|Thu 28 Sep 2017): tags specs will go here once launched
      context "admin user" do
        let(:user) { create_admin_user }
        let(:tags) { Array.new(2) { create(:tag) } }

        context "when person has tags" do
          before do
            tags.each{ |t| person.tag(t.id) }
            refresh_page
          end

          it "shows a tag edit button" do
            subject_has_selector "#tags-edit-button"
          end

          it "shows tags" do
            subject_has_selector "a.tag", count: 2
          end
        end
      end
    end
  end

  describe "navigation tabs" do
    let(:subpage_links) do
      [{ text: 'Relationships',  path: entity_path(person) },
       { text: 'Interlocks',     path: interlocks_entity_path(person) },
       { text: 'Giving',         path: giving_entity_path(person) },
       { text: 'Political',      path: political_entity_path(person) },
       { text: 'Data',           path: datatable_entity_path(person) }]
    end

    it "has tabs for every subpage" do
      subpage_links.each do |link|
        expect(page).to have_link(link[:text], href: link[:path])
      end
    end

    it "defaults to relationships tab" do
      expect(page).to have_current_path entity_path(person)
      expect(page.find('div.button-tabs span.active'))
        .to have_link('Relationships')
    end

    # TODO(ag|04-Oct-2017): delete this after playing card #336 (and eliminating legacy url)
    context "for an org" do
      it "uses the legacy url for the giving tab" do
        visit entity_path(org)
        expect(page).to have_link('Giving', href: org.legacy_url('giving'))
      end
    end
  end

  xdescribe "relationships tab" do
    it "shows a series of lists"
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
              .to have_link(person.name, href: entity_path(people[3]))
          end

          it "displays interlocking orgs' names as links in same row as interlocked people" do
            orgs.each do |org|
              expect(subject.find('.connecting-entities-cell'))
                .to have_link(org.name, href: entity_path(org))
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
            .to have_link(org.name, href: entity_path(orgs[3]))
        end

        it "displays interlocking peoples' names as links in same row as interlocked org" do
          people.each do |person|
            expect(subject.find('.connecting-entities-cell'))
              .to have_link(person.name, href: entity_path(person))
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
            .to have_link(root_entity.name, href: entity_path(donors[3]))
        end

        it "displays connecting recipients' names as links in same row as connected donors" do
          recipients.each do |r|
            expect(subject.find('.connecting-entities-cell'))
              .to have_link(r.name, href: entity_path(r))
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

      it "shows a table header for connected entities" do
        expect(page.find("#connected-entity-header")).to have_text "Recipient"
      end

      it "shows a table header for connecting entities" do
        expect(page.find("#connecting-entity-header")).to have_text "Donors"
      end

      describe "first row" do
        subject { page.all("#entity-connections-table tbody tr").first }

        it "displays the most-donated-to recipient's name as link" do
          puts subject.find('.connected-entity-cell').text
          expect(subject.find('.connected-entity-cell'))
            .to have_link(root_entity.name, href: entity_path(recipients[3]))
        end

        it "displays connecting donors' names as links in same row as connected recipient" do
          donors.each do |d|
            expect(subject.find('.connecting-entities-cell'))
              .to have_link(d.name, href: entity_path(d))
          end
        end
      end
    end
  end
end
