require 'rails_helper'

describe "Relationship Page", :type => :feature do
  before(:all) { @user = create_user_with_sf }
  let(:org) { create(:org) }
  let(:person) { create(:org) }
  let(:relationship) do
    rel = Relationship.create!(category_id: 12, entity: org, related: person, last_user_id: @user.sf_guard_user.id)
    Reference.create!(object_id: rel.id, object_model: "Relationship", source: "https://example.com")
    rel
  end

  context "Anonymous user" do
    before(:each) do
      visit "/relationships/#{relationship.id}"
    end

    it 'has relationship title' do
      expect(page).to have_selector 'h1.relationship-title-link a', text: relationship.name
    end

    context 'source links' do
      it 'has one source link' do
        expect(page).to have_selector '#source-links-table tbody tr', count: 1, text: "https://example.com"
      end

      it 'opens the source links in a new tab' do
        page.all('#source-links-table tbody tr a').each do |element|
          expect(element[:target]).to eql '_blank'
        end
      end
    end
  end
end
