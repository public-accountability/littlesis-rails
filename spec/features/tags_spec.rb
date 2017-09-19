require 'rails_helper'

describe 'Tags', type: :feature do

  let(:tags) { Array.new(2) { create(:tag) } }
  let(:tag) { tags.first }

  # setup helpers

  def n_entities (n)
    Array.new(n) { create(:entity_org) }
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
     tags.each do |tag|
       expect(page.find("#tags-index-list"))
         .to have_selector ".item", count: tags.size
      end
    end

    it "shows a link to each tag's homepage" do
     tags.each{ |tag| expect(page).to have_link(tag.name, href: tag_path(tag)) }
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

    context "with no tab specified" do
      before { visit "/tags/#{tag.id}" }

      it "defaults to the entities tab" do
        expect(page).to have_selector("#tag-nav-tab-entities.active")
      end

      it "shows the tag title and description" do
        expect(page).to have_text tag.name
        expect(page).to have_text tag.description
      end

      # NOTE(ag|Thu 14 Sep 2017): this test would make more sense below
      # *but* because we can't programatically set the description for
      # every tagable in the same way, we do it here for convenience
      it "truncates descriptions longer than 90 characters" do
        n_tagables(1, Entity.category_str)
          .first
          .tag(tag.id)
          .update(blurb: ("a" * 91))
        refresh_page
        expect(
          page.all("#tagable-list .tagable-list-item-description").first.text
        ).to eq("a" * 87 + "...")
      end
    end

    Tagable.classes.map(&:category_str).each do |tagable_category|

      context "on #{tagable_category} tab" do

        context "no tagged #{tagable_category}" do
          before { visit "/tags/#{tag.id}/#{tagable_category}"}

          it "shows an empty list message" do
            expect(page).not_to have_selector '.tagable-list-item'
            expect(page.find("#tagable-list")).to have_text "no #{tagable_category} tagged"
          end
        end

        context "less than 20 tagged #{tagable_category}" do
          let(:tagables) do
            n_tagables(2, tagable_category).map { |t| t.tag(tag.id) }
          end

          before do
            tagables
            visit "/tags/#{tag.id}/#{tagable_category}"
          end

          it "shows the tag title and description" do
            expect(page).to have_text tag.name
            expect(page).to have_text tag.description
          end

          it "shows a list of tagged entities" do
            expect(page.find("#tagable-list"))
              .to have_selector '.tagable-list-item', count: 2
          end

          it "renders the name of each #{tagable_category.singularize} as a link" do
            page.all("#tagable-list .tagable-list-item").each_with_index do |item, i|
              expect(item).to have_link :class => 'tagable-list-item-name'
            end
          end

          it "shows a description of each #{tagable_category.singularize}" do
            page.all("#tagable-list .tagable-list-item").each_with_index do |item, i|
              tagable = tagables.reverse[i] # b/c sorting by update reversed order
              expect(item.find(".tagable-list-item-description")).to have_text(tagable.description)
            end
          end

          it "displays last updated date for each #{tagable_category.singularize}" do
            page.all("#tagable-list .tagable-list-item").each do |item|
              sort_text = tagable_category == 'entities' ? 'relationships' : 'ago'
              expect(item.find(".tagable-list-item-sort-info")).to have_text sort_text
            end
          end
        end

        context "more than 20 tagged #{tagable_category}" do
          let(:tagables) { n_tagables(21, tagable_category) }
          before do
            tagables.map { |t| t.tag(tag.id) }
            visit "/tags/#{tag.id}/#{tagable_category}"
          end

          it "only shows 10 entities with pagination bar" do
            expect(page.find("#tagable-list"))
              .to have_selector '.tagable-list-item', count: 20
          end
        end
      end
    end
  end
end
