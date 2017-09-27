require 'rails_helper'

describe "Entity Page", :interlocks_helper, :pagination_helper, type: :feature do
  # TODO: include Routes (which will force internal handling of /people/..., /orgs/... routes)
  let(:user) { create_basic_user }
  let(:person){ create(:entity_person, last_user_id: user.sf_guard_user.id) }
  let(:org){ create(:entity_org, last_user_id: user.sf_guard_user.id) }

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

  describe "header/chrome" do
    it "shows the entity's name" do
      expect(page.find("#entity-name")).to have_text person.name
    end

    it "shows a description of the entity" do
      expect(page.find("#entity-blurb")).to have_text person.blurb
    end

    it "shows action buttons" do
      expect(page).to have_selector ".action-button", count: 3
    end

    it "shows social media buttons" do
      expect(page).to have_selector ".fb-share-button"
      expect(page).to have_selector ".twitter-share-button"
    end

    context 'user is signed in' do
      it 'show advanced user action buttons'
    end
  end

  describe "summary field" do
    it "hides the summary field if user has no summary" do
      expect(page.find("#entity-summary")).not_to have_text person.summary_excerpt
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
  
  describe "navigation tabs" do

    it "has 5 tabs"
    
    it "defaults to relationships tab" do
      expect(page).to have_current_path entity_path(person)
      expect(page.find('div.button-tabs span.active')).to have_text 'Relationships'
    end

    it "visits a subpage when a user clicks on a tab"
  end

  xdescribe "sidebar" do

    it "shows an edit history"
    
    it "shows an image"

    it "shows a basic info section"

    it "shows a source links section"

    it "shows a lists section containing lists that person is in"

    it "shows a tags section"
    
    context "logged in" do
      
      it "shows a tag edit button"

      it "shows advaced tools section"

      it "shows a similar entities section"
      
      context "admin" do
        it "shows an admin tools section"
      end
    end
  end

  xdescribe "relationships tab" do
    it "shows a series of lists"
  end
  
  describe "interlocks tab" do
    let(:people) { Array.new(4) { create(:entity_person, last_user_id: APP_CONFIG['system_user_id']) } }
    let(:person) { people.first }
    let(:orgs) { Array.new(3) { create(:entity_org) } }
    before do
      interlock_people_via_orgs(people, orgs)
      visit interlocks_entity_path(person)
    end
    
    describe "main container" do
      
      it 'on the interlocks tab' do
        expect(page).to have_current_path interlocks_entity_path(person)
      end

      it "shows a header and subheader" do
        expect(page.find("#entity-interlocks-title"))
          .to have_text "People in Common Orgs"
        expect(page.find("#entity-interlocks-subtitle"))
          .to have_text "same orgs as #{person.name}"
      end

      it "has a table of connected entites" do
        expect(page.find("#entity-interlocks-table tbody")).to have_selector "tr", count: 3
      end

      describe "first row" do
        subject { page.all("#entity-interlocks-table tbody tr").first }

        it "displays the most-interlocked person's name as link" do
          expect(subject.find('.connected-entity-cell'))
            .to have_link(person.name, href: "/person/#{people[3].to_param}")
        end

        it "displays interlocking orgs' names as links in same row as interlocked people" do
          orgs.each do |org|
            expect(subject.find('.connecting-entities-cell'))
              .to have_link(org.name, href: "/org/#{org.to_param}")
          end
        end
      end

      describe "pagination" do
        
        context "less than #{Entity::PER_PAGE} interlocks" do
          it "does not show a pagination bar" do
            expect(page.find("#entity-interlocks-pagination"))
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
            expect(page.find("#entity-interlocks-pagination"))
              .to have_selector(".pagination")
          end

          it "only shows #{Entity::PER_PAGE} rows" do
            expect(page.find("#entity-interlocks-table tbody"))
              .to have_selector "tr", count: Entity::PER_PAGE
          end
        end
      end
    end
  end
end
