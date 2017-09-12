require 'rails_helper'

describe 'Tags', type: :feature do

  let(:tags) { Array.new(2) { create(:tag) } }
  let(:tag) { tags.first }
  let(:entities) { Array.new(11) { create(:org) } }
  let(:lists) { Array.new(11) { create(:list) } }
  let(:relationships) do
    Array.new(11) do
      create(:generic_relationship, entity: entities.first, related: entities.second)
    end
  end
  let(:tagables) { [entities, lists, relationships] }
  
  
  # before(:all) do
  #   # we use instance variables here as a performance optimization to trim seconds off of this suite
  #   tags = Array.new(2) { create(:tag) }
  #   tag = tags.first
  #   entities = Array.new(11) { create(:org) }
  #   lists = Array.new(11) { create(:list) }
  #   relationships = Array.new(11) do
  #     create(:generic_relationship, entity: entities.first, related: entities.second)
  #   end
  #   tagables = [entities, lists, relationships]
  #   #avoid inadvertantly re-setting entity `updated_at` field when we set relationship `updated_at` field
  #   Relationship.skip_callback(:save, :after, :update_entity_timestamps)
  # end

  # after(:all) { Relationship.set_callback(:save, :after, :update_entity_timestamps) }

  # setup helpers
  def update_time(tagable, i)
    tagable.update_columns(updated_at: Time.now - (4 / (i + 1)).days)
  end

  def n_tagables(n)
    tagables.map { |ts| ts.take(n) }.flatten
  end

  def name_of(tagable_class)
    tagable_class.to_s.downcase.pluralize
  end

  def list_items_for(tagable_class)
    page.all("#tagable-list-#{name_of(tagable_class)} .tagable-list-item")
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
    context "with no taggings" do
      before { visit "/tags/#{tag.id}" }

      it "shows the tag title and description" do
        expect(page).to have_text tag.name
        expect(page).to have_text tag.description
      end

      it "shows empty lists for all tagable types" do
        Tagable::TAGABLE_CLASSES.each { |tc| should_be_empty_for(tc) }
      end

      def should_be_empty_for(tagable_class)
        list = page.find("#tagable-list-#{name_of(tagable_class)}")
        expect(list).to have_text "no #{name_of(tagable_class)} tagged"
        expect(list).not_to have_selector '.tagable-list-item'
      end
    end

    context "with less than 10 taggings" do

      before do
        n_tagables(2).each_with_index do |tagable, i|
          # set dates for each collection in chronological order
          # so that we will expect view to sort them in reverse
          offset = 4 / ((i % 2) + 1)
          tagable
            .tag(tag.id)
            .update_columns(updated_at: Time.now - offset.days)
        end
        visit "/tags/#{tag.id}"
      end
      
      it "shows a list of tagables for each tagable type" do
        Tagable::TAGABLE_CLASSES.each { |tc| should_show_tagable_list_for(tc) }
      end

      def should_show_tagable_list_for(tagable_class)
        expect(page.find("#tagable-list-#{name_of(tagable_class)}"))
          .to have_selector '.tagable-list-item', count: 2
      end

      it "renders the name of each tagable as a link" do
        Tagable::TAGABLE_CLASSES.each_with_index do |tc, i|
          should_show_name_as_link_for(tc, tagables[i])
        end
      end

      def should_show_name_as_link_for(tagable_class, tagable_collection)
        list_items_for(tagable_class).each_with_index do |item, i|
          link = item.find('a.tagable-list-item-name')
          tagable = tagable_collection.take(2).reverse[i] # b/c sorting by update reversed order
          expect(link).to have_text(tagable.name.titlecase)
          expect(link[:href]).to include(tagable.id.to_s)
        end
      end

      it "shows a description of each tagable" do
        Tagable::TAGABLE_CLASSES.each_with_index do |tc, i|
          should_show_description_for(tc, tagables[i])
        end
      end

      def should_show_description_for(tagable_class, tagable_collection)
        list_items_for(tagable_class).each_with_index do |item, i|
          tagable = tagable_collection.take(2).reverse[i] # b/c sorting by update reversed order
          expect(item.find(".tagable-list-item-description")).to have_text(tagable.description)
        end
      end

      it "displays last updated date for each tagable" do
        Tagable::TAGABLE_CLASSES.each do |tc|
          should_show_date_for(tc)
        end
      end

      def should_show_date_for(tagable_class)
        list_items_for(tagable_class).each do |item|
          expect(item.find(".tagable-list-item-date")).to have_text("ago")
        end
      end

      it "sorts each tagble list in reverse chronological order of last update" do
        Tagable::TAGABLE_CLASSES.each do |tc|
          should_be_sorted_by_update_date(tc)
        end
      end

      def should_be_sorted_by_update_date(tagable_class)
        dates = list_items_for(tagable_class).map { |x| x.find(".tagable-list-item-date") }
        expect(dates.first).to have_text "2 days ago"
        expect(dates.second).to have_text "4 days ago"
      end

      it "truncates descriptions longer than 90 charcaters" do
        lists[1].update(description: "a" * 91) # second b/c sorting reverses order
        visit "/tags/#{tag.id}"

        expect(page.all("#tagable-list-lists .tagable-list-item-description").first.text)
          .to eq "a" * 87 + "..."
      end
    end

    context "with more than 10 taggings" do
      before do
        n_tagables(11).map { |t| t.tag(tag.id) }
        visit "/tags/#{tag.id}"
      end

      it "only shows 10 tagables for each tagable type" do
        Tagable::TAGABLE_CLASSES.each { |tc| should_paginate_for(tc) }
      end

      def should_paginate_for(tagable_class)
        expect(page.find("#tagable-list-#{name_of(tagable_class)}"))
          .to have_selector '.tagable-list-item', count: 10
      end
    end
  end
end
;
