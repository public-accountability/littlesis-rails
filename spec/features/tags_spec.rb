require 'rails_helper'

describe 'Tags', type: :feature do

  let(:tags) { Array.new(2) { create(:tag) } }
  let(:tag) { tags.first }

  # setup helpers

  def n_entities (n, subtype = 'Person')
    Array.new(n) { create("entity_#{subtype.downcase}".to_sym) }
  end

  def n_lists (n)
    Array.new(n) { create(:list) }
  end

  def relate(x,y)
    create(:generic_relationship, entity: x, related: y)
  end

  def n_relationships(n)
    Array.new(n) { relate(create(:entity_org), create(:entity_org)) }
  end

  def n_tagables(n, tagable_category)
    send("n_#{tagable_category}".to_sym, n)
  end

  describe "tag index" do
    before do
      tags
      visit "tags/"
    end

    it "has a title" do
      expect(page).to have_selector "#tags-index-title"
    end

    it "has a description" do
      expect(page).to have_selector "#tags-index-description"
    end

    it "links to the tag request form" do
      expect(page.find("#tags-index-description"))
        .to have_link("this form", href: tags_request_path)
    end

    it "shows a list of all tags" do
      expect(page.find("#tags-index-list"))
        .to have_selector ".item", count: tags.size
    end

    it "shows a link to each tag's homepage" do
      tags.each { |tag| expect(page).to have_link(tag.name, href: tag_path(tag)) }
    end

    it "shows a description of each tag" do
      tags.each { |tag| expect(page).to have_text(tag.description) }
    end

    it "sorts tags in alphabetical order" do
      create(:tag, name: "aa")
      refresh_page
      expect(page.all("#tags-index-list .item")[0]).to have_text("aa")
    end
  end

  describe "tag homepage" do

    describe "tabs" do
      let(:tagable_category) { "" }
      let(:tagables) { [] }
      before(:each) do
        tagables
        visit "/tags/#{tag.id}/#{tagable_category}"
      end

      context "with no tab specified" do

        it "defaults to the entities tab" do
          expect(page).to have_selector("#tag-nav-tab-entities.active")
        end

        it "shows the tag title and description" do
          expect(page).to have_text tag.name
          expect(page).to have_text tag.description
        end

        it "shows edit tab"
      end

      Tagable.categories.each do |tagable_category|
        context "on #{tagable_category} tab" do
          let(:tagable_category) { tagable_category }

          if tagable_category == Entity.category_sym
            let(:tagables) { n_entities(1, 'Person') + n_entities(1, "Org") }

            context "#{tagable_category} is grouped by subtype" do
              it "shows a tagable list for each subtype" do
                expect(page).to have_selector ".tagable-list", count: 2
              end

              it "shows a subheader for each tag list" do
                expect(page).to have_selector ".tagable-list-subheader", count: 2
              end
            end

          else
            let(:tagables) { n_tagables(1, tagable_category) }
            context "#{tagable_category} is not grouped by type" do

              it "shows one tag list" do
                expect(page).to have_selector ".tagable-list-items", count: 1
              end
              it "does not show a tag list subheader" do
                expect(page).not_to have_selector ".tagable-list-subheader"
              end
            end
          end
        end
      end
    end

    describe "a tagable list" do
      # we use entities here arbitrarily
      let(:tagable_category) { 'entities' }
      let(:tagables) { [] }
      let(:list) { page.all(".tagable-list").first }

      before do
        tagables
        visit "/tags/#{tag.id}/#{tagable_category}"
      end

      context "no tagged items" do
        it "shows an empty list message" do
          expect(page).not_to have_selector '.tagable-list-item'
          expect(page).to have_text "There are no"
        end
      end

      context "less than 20 tagged tagables" do
        let(:tagables) do
          n_tagables(2, tagable_category).map { |t| t.tag(tag.id) }
        end

        it "shows the tag title and description" do
          expect(page).to have_text tag.name
          expect(page).to have_text tag.description
        end

        it "shows a list of tagables" do
          expect(list).to have_selector '.tagable-list-item', count: 2
        end

        it "renders the name of each tagable as a link" do
          list.all(".tagable-list-item").each do |item|
            expect(item).to have_link :class => 'tagable-list-item-name'
          end
        end

        it "shows a description of each tagable" do
          list.all(".tagable-list-item").each do |item|
            expect(item).to have_selector ".tagable-list-item-description"
          end
        end

        it "displays last updated date for each tagable" do
          list.all(".tagable-list-item").each do |item|
            sort_text = tagable_category == 'entities' ? 'relationships' : 'ago'
            expect(item.find(".tagable-list-item-sort-info")).to have_text sort_text
          end
        end

        it "truncates descriptions longer than 90 characters" do
          tagables.first.update(blurb: ("a" * 91))
          refresh_page
          expect(page).to have_text("a" * 87 + "...")
        end
      end

      context "more than 20 tagables" do
        let(:tagables) { n_tagables(21, tagable_category).map { |t| t.tag(tag.id) } }
        it "only shows 10 entities with pagination bar" do
          expect(page.find("#tagable-lists"))
            .to have_selector '.tagable-list-item', count: 20
        end
      end
    end

    describe 'edits tab' do
      it "has header with text edits"

      it "contains list of edits"

      describe 'list of edits' do
        it "contains recently edited entity that is tagged"

        it "contains entity that was recently tagged (add tag)"

        it "contains entity that was recently un-tagged"

        it "containts list that was recently tagged"

        it "contains list that was recently updated"
      end
    end # end describe edits tab
  end # end describe tag homepage
end
