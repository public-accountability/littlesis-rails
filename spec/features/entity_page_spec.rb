require 'rails_helper'

describe "Entity Page", :interlocks_helper, type: :feature do
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

  it "defaults to relationships tab" do
    expect(page).to have_current_path entity_path(person)
    expect(page.find('div.button-tabs span.active')).to have_text 'Relationships'
  end

  it "shows the entity's name" do
    expect(page).to have_selector("#entity-name")
  end

  it "shows a subtititle" do
    expect(page).to have_selector("#entity-subtitle")
  end

  it "shows edit buttons" do
    expect(page).to have_selector ".action-button", count: 3
  end
      it "shows a similar entities section"

  it "shows social media buttons" do
    expect(page).to have_selector ".fb-share-button"
    expect(page).to have_selector ".twitter-share-button"
  end

  context 'user is signed in' do
    it 'show advanced user buttons'
  end
  

  it "shows a description"

  it "has 5 tabs"

  it "navigates to tab subpage when tab is clicked"

  describe "sidebar" do

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
    before { interlock_people_via_orgs(people, orgs)  }
    
    describe "main container" do

      before { visit interlocks_entity_path(person) }
      
      it 'on the interlocks tab' do
        expect(page).to have_current_path interlocks_entity_path(person)
      end

      it "shows a header and subheader" do
        expect(page.find("#entity-interlocks-tab-title"))
          .to have_text "People in Common Orgs"
        expect(page.find("#entity-interlocks-tab-subtitle"))
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
          it "does not show a pagination bar"
        end
        
        context "less than #{Entity::PER_PAGE} interlocks" do
          it "shows a pagination bar"

          it "only shows #{Entity::PER_PAGE} rows"

          it "shows the page that a user clicks on"
        end
      end
    end
  end
end
