require 'rails_helper'

describe "Relationship Page", :type => :feature do
  let(:user) { create_basic_user }
  let(:org) { create(:entity_org) }
  let(:person) { create(:entity_person) }
  let(:url) { 'http://example.com' }

  let(:relationship) do
    rel = Relationship.create!(category_id: 12, entity: org, related: person, last_user_id: user.sf_guard_user.id)
    rel.add_reference(url: url)
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
        expect(page).to have_selector '#source-links-table tbody tr', count: 1, text: url
      end

      it 'opens the source links in a new tab' do
        page.all('#source-links-table tbody tr a').each do |element|
          expect(element[:target]).to eql '_blank'
        end
      end
    end
  end
end
