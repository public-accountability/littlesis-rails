require 'rails_helper'

describe 'Tags', type: :feature do

  let(:time_offset) { ->(n) { Time.now - (4 / (n + 1)).days } }
  let(:tag) { create(:tag) }
  let(:entities) { Array.new(11) { create(:org)  } }
  let(:lists) { Array.new(11) { create(:list) } }
  let(:relationships) do
    Array.new(11) do
      create(:generic_relationship, entity: entities.first, related: entities.second)
    end
  end
  let(:tagables) { [entities, lists, relationships] }

  # def n_tagables(n, transform = nil)
  #   tagables.map do |t|
  #     t.take(n).tap { |ts| transform&.call(ts) }
  #   end.flatten
  # end

  def n_tagables(n)
    tagables.map { |ts| ts.take(n) }.flatten
  end

  def name_of(tagable_class)
    tagable_class.to_s.downcase.pluralize
  end

  def list_items_for(tagable_class)
    page.all("#tagable-list-#{name_of(tagable_class)} .tagable-list-item")
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
        n_tagables(2).each{ |t| t.tag(tag.id) }
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
          tagable = tagable_collection[i]
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
          tagable = tagable_collection[i]
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


      describe "sorting" do
        before do
          # so that we don't interfere with update_time on entities in a relationship:
          Relationship.skip_callback(:save, :after, :update_entity_timestamps)
          n_tagables(2).each_with_index do |t, i|
            # there are 2 elements for each class in our example set
            offset = (i % 2) + 1
            # we want the last elements to be most recently edited (so that sort must move them)
            t.tag(tag.id).update_columns(updated_at: Time.now - (4 / offset).days)
          end
          visit "/tags/#{tag.id}"
        end

        after do
          Relationship.set_callback(:save, :after, :update_entity_timestamps)
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
