require 'rails_helper'

describe 'Homepage' do
  let(:entity) { create(:entity_org) }
  let(:list) { create(:list) }

  before do
    allow_any_instance_of(HomeController).to receive(:carousel_entities).and_return([entity])
    stub_const("HomeController::DOTS_CONNECTED_LISTS", [[list.id, 'Corporate fat cats']])
  end

  feature 'visting the home page' do
    before { visit '/' }

    scenario 'anonymous user visiting the home page' do
      expect(page.status_code).to eq 200

      page_has_selector 'h1', text: 'LittleSis* is a free database of who-knows-who at the heights of business and government.'
    end
  end
end
