require "rails_helper"

describe 'Entity: Interlocks', type: :model do

  context "for a person" do
    let(:people) { Array.new(4) { create(:entity_person) } }
    let(:person) { people.first }
    let(:orgs) { Array.new(3) { create(:entity_org) } }
    before do
      # person[0] is related to all orgs, person[n] is related to n orgs
      people.each_with_index do |person, idx|
        (idx.zero? ? orgs : orgs.take(idx)).each do |org|
          create(:position_relationship, entity: person, related: org)
        end
      end
    end

    subject { person.interlocks.to_a }

    it "returns a list of people in common orgs" do
      expect(subject)
        .to eq([
                 {
                   "person" => people[3],
                   "orgs" => orgs.take(3)
                 },
                 {
                   "person" => people[2],
                   "orgs" => orgs.take(2)
                 },
                 {
                   "person" => people[1],
                   "orgs" => orgs.take(1)
                 }
               ])
    end
  end
end
