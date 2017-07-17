require 'rails_helper'

describe ToolsHelper, type: :helper do
  before do
    @html_org = helper.relationship_select_builder('Org').to_s
    @html_person = helper.relationship_select_builder('Person').to_s
  end

  it 'puts family only for person' do
    expect(@html_org).not_to include 'Family'
    expect(@html_person).to include 'Family'
  end

  it 'includes position for both' do
    expect(@html_org).to include 'Position'
    expect(@html_person).to include 'Position'
  end

  it 'does not include regular donation (cat #5)' do
    expect(@html_org).not_to include 'value="5"'
    expect(@html_person).not_to include 'value="5"'
  end

  it 'includes Donations Received and Given Tags' do
    expect(@html_org).to include 'Donations Received'
    expect(@html_person).to include 'Donations Received'
    expect(@html_org).to include 'Donations Given'
    expect(@html_person).to include 'Donations Given'
  end
end
