# coding: utf-8
require 'rails_helper'

describe Link, type: :model do
  it { should belong_to(:relationship) }
  it { should belong_to(:entity) }
  it { should belong_to(:related) }
  it { should have_many(:chained_links) }

  def org_with_type(type)
    org = create(:org)
    org.add_extension(type)
    org
  end

  def person_with_type(type)
    person = create(:person)
    person.add_extension(type)
    person
  end

  describe '#position_type' do
    it 'returns "none" for non-position relationships' do
      expect(build(:link, category_id: 2).position_type).to eq 'None'
      expect(build(:link, category_id: 3).position_type).to eq 'None'
      expect(build(:link, category_id: 12).position_type).to eq 'None'
    end

    it 'returns business if other entity is a Business' do
      org = org_with_type('Business')
      link = build(:link, category_id: 1, entity2_id: org.id)
      expect(link.position_type).to eq 'business'
    end

    it 'returns business if other entity is a businessPerson' do
      person = person_with_type('BusinessPerson')
      link = build(:link, category_id: 1, entity2_id: person.id)
      expect(link.position_type).to eq 'business'
    end

    it 'returns government if other entity is a gov' do
      org = org_with_type('GovernmentBody')
      link = build(:link, category_id: 1, entity2_id: org.id)
      expect(link.position_type).to eq 'government'
    end

    it 'returns office if other entity is a PublicOfficial' do
      person = person_with_type('PublicOfficial')
      link = build(:link, category_id: 1, entity2_id: person.id)
      expect(link.position_type).to eq 'office'
    end

    it 'returns office if other entity is a elected' do
      person = person_with_type('ElectedRepresentative')
      link = build(:link, category_id: 1, entity2_id: person.id)
      expect(link.position_type).to eq 'office'
    end

    it 'returns "other" if entity is sothing else' do
      org = org_with_type('LaborUnion')
      link = build(:link, category_id: 1, entity2_id: org.id)
      expect(link.position_type).to eq 'other'
    end
  end

  describe 'description' do
    it 'calls relationship.title if relationship is position' do
      rel = build(:relationship, category_id: 1)
      link = build(:link, relationship: rel, category_id: 1)
      expect(rel).to receive(:title).once
      link.description
    end

    it 'calls relationship.title if relationship is membership' do
      rel = build(:relationship, category_id: 3)
      link = build(:link, relationship: rel, category_id: 3)
      expect(rel).to receive(:title).once
      link.description
    end

    it 'returns humanized contirbution if is campaign contribution' do
      rel = build(:donation_relationship, filings: nil, amount: 2000000, description1: "Campaign Contribution")
      link = build(:link, relationship: rel, category_id: 5)
      expect(link.description).to eq "Donation · $2,000,000"
    end

    it 'returns humanized contirbution for NYS campaign contribution with 0 filings' do
      rel = build(:donation_relationship, filings: nil, amount: 1000000, description1: "NYS Campaign Contribution")
      link = build(:link, relationship: rel, category_id: 5)
      expect(link.description).to eq "NYS Campaign Contribution · $1,000,000"
    end

    it 'returns humanized contirbution for NYS campaign contribution with 2 filings' do
      rel = build(:donation_relationship, filings: 2, amount: 1000000, description1: "NYS Campaign Contribution")
      link = build(:link, relationship: rel, category_id: 5)
      expect(link.description).to eq "2 contributions · $1,000,000"
    end

    it 'returns humanized contribution for other donations' do
      rel = build(:donation_relationship, filings: nil, amount: 1000, description1: nil)
      link = build(:link, relationship: rel, category_id: 5)
      expect(link.description).to eq "Donation/Grant · $1,000"
    end

    it 'returns humanized contribution for other donations with custom type' do
      rel = build(:donation_relationship, filings: nil, amount: 1000, description1: 'suspicious contribution')
      link = build(:link, relationship: rel, category_id: 5)
      expect(link.description).to eq "suspicious contribution · $1,000"
    end
  end

  describe '#humanize_contributions' do
    it 'creates correct str when there are filings' do
      rel = build(:donation_relationship, filings: 3, amount: 1000)
      link = build(:link, relationship: rel, category_id: 5)
      expect(link.send(:humanize_contributions)).to eq "3 contributions · $1,000"
    end

    it 'creates correct str when filings is 0 or nil' do
      rel = build(:donation_relationship, filings: nil, amount: 2000000)
      link = build(:link, relationship: rel, category_id: 5)
      expect(link.send(:humanize_contributions)).to eq "Donation/Grant · $2,000,000"
      rel2 = build(:donation_relationship, filings: 0, amount: 2000000, description1: 'Campaign Contribution')
      link2 = build(:link, relationship: rel2, category_id: 5)
      expect(link2.send(:humanize_contributions)).to eq "Donation · $2,000,000"
    end
  end

  describe '#education description' do
    def make_link(field: nil, description1: nil, degree_id: nil)
      education = build(:education, degree_id: degree_id, field: field) 
      edu_rel = build(:education_relationship, education: education, description1: description1)
      build(:link, category_id: Relationship::EDUCATION_CATEGORY, relationship: edu_rel)
    end

    it 'shows degree abbreviation if it exists' do
      link = make_link degree_id: 2
      expect(link.description).to eq "BA"
    end

    it 'shows field if it exists' do
      link = make_link field: 'Psychology', degree_id: 2
      expect(link.description).to eq "BA, Psychology"
    end

    it 'shows description1 when not degree or field information' do
      link = make_link description1: "Undergraduate"
      expect(link.description).to eq "Undergraduate"
    end

    it 'shows default description' do
      expect(['School', 'Student']).to include make_link.send(:education_description)
    end

    it 'shows full degree name if no abbreviation exists' do
      link = make_link degree_id: 12
      expect(link.description).to eq "Honorus Degree"
    end

    it 'handles nil education' do
      link = build(:link, relationship: build(:education_relationship), category_id: 2)
      expect(['School', 'Student']).to include link.send(:education_description)
    end
  end
end
