require 'rails_helper'

describe 'Tags', :tag_helper, type: :feature do
  seed_tags

  let(:oil_tag) { Tag.find_by_name("oil") }
  let(:orgs) { (0..3).map { |n| create(:org, name: "org#{n}") } }
  let(:person) { create(:person) }

  describe "tag homepage" do
    context "with taggings" do
      before do
        ([person] + orgs).each { |x| x.tag(oil_tag.id) }
        visit "/tags/#{oil_tag.id}"
      end

      it "shows the tag title and description" do
        expect(page).to have_text oil_tag.name
        expect(page).to have_text oil_tag.description
      end

      it "shows a list of tagged items" do
        expect(page.all(".tagable-list-item").length).to eq 5
      end

      it "sorts tagged items by # of relationships to items with same tag"
    end

    context "with no taggings" do
      before { visit "/tags/#{oil_tag.id}" }

      it "shows an empty list" do
        expect(page.all(".tagable-list-item")).to be_empty
        expect(page.find(".tagable-list")).to have_text "no items with tag"
      end
    end
  end
end
