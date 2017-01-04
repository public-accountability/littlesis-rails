require 'rails_helper'
require Rails.root.join('lib', 'task-helpers', 'fec_links.rb')

describe 'FecLinks' do
  before(:all) do
    l = create(:list)
    @ref1 = create(:ref, source: 'http://query.nictusa.com/link1', object_id: l.id)
    @ref2 = create(:ref, source: 'http://query.nictusa.com/link2', object_id: l.id)
    @ref3 = create(:ref, source: 'http://cats.net/cat', object_id: l.id)
    FecLinks.update
  end

  it 'replaces query.nictusa.com with docquery.fec.gov' do
    expect(Reference.where("source like 'http://query.nictusa.com/%'").count).to eq(0)
    expect(Reference.where("source like 'http://docquery.fec.gov/%'").count).to eq(2)
  end

  it 'updates links correctly' do
    expect(Reference.find(@ref1.id).source).to eql('http://docquery.fec.gov/link1')
    expect(Reference.find(@ref2.id).source).to eql('http://docquery.fec.gov/link2')
  end

  it 'does not change other records' do
    expect(Reference.find(@ref3.id).source).to eql('http://cats.net/cat')
  end
end
