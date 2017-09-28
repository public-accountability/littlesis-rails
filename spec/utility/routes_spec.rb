require "rails_helper"

describe Routes, type: :feature do
  let(:org) { build(:org) }
  let(:person) { build(:person) }

  it 'changes path prefix from entities' do
    expect(entity_path(org)).to eql "/org/#{org.to_param}"
    expect(entity_path(person)).to eql "/person/#{person.to_param}"
  end

  it 'changes member routes' do
    expect(interlocks_entity_path(org)).to eql "/org/#{org.to_param}/interlocks"
  end

  it 'does not change post routes' do
    expect(match_donation_entity_path(org)).to eql "/entities/#{org.to_param}/match_donation"
  end

  it 'modifies URL helpers' do
    expect(interlocks_entity_url(org)).to eql "http://www.example.com/org/#{org.to_param}/interlocks"
  end
end
