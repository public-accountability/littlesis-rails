require 'rails_helper'

describe 'Tags', type: :feature do

  let(:tag) { create(:tag) }
  let(:entities) { Array.new(11) { create(:org) } }
  let(:lists) { Array.new(11) { create(:list) } }
  let(:relationships) do
    Array.new(11) do
      create(:generic_relationship, entity: entities.first, related: entities.second)
    end
  end
  let(:tagables) { [entities, lists, relationships] }

  def n_tagables(n)
    tagables.map { |t| t.take(n) }.flatten
  end

  def name_of(tagable_class)
    tagable_class.to_s.downcase.pluralize
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
        n_tagables(2).map { |t| t.tag(tag.id) }
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
        list_items = page.all("#tagable-list-#{name_of(tagable_class)} .tagable-list-item")
        list_items.each_with_index do |item, i|
          link = item.find('a.tagable-list-name')
          tagable = tagable_collection[i]
          expect(link).to have_text(tagable.name.titlecase)
          expect(link[:href]).to include(tagable.id.to_s)
        end
      end

      it "shows a description of each tagable"

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
