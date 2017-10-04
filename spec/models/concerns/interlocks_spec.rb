require "rails_helper"

describe 'Entity: Interlocks', :interlocks_helper, :pagination_helper, type: :model do

  context "for a person" do
    let(:people) { Array.new(4) { create(:entity_person) } }
    let(:person) { people.first }
    let(:orgs) { Array.new(3) { create(:entity_org) } }

    before { interlock_people_via_orgs(people, orgs) }

    context "with less interlocks than pagination limit" do

      it "lists all people in common orgs" do
        expect(person.interlocks.to_a)
          .to eq([
                   {
                     "connected_entity"    => people[3],
                     "connecting_entities" => orgs.take(3)
                   },
                   {
                     "connected_entity"    => people[2],
                     "connecting_entities" => orgs.take(2)
                   },
                   {
                     "connected_entity"    => people[1],
                     "connecting_entities" => orgs.take(1)
                   }
                 ])
      end
    end

    context "with more interlocks than pagination limit" do
      stub_page_limit(Entity)
      # we have to create 1 more person than interlocks we expect to see
      # because the first person is the one to whom the others are interlocked
      let(:people) { Array.new(Entity::PER_PAGE + 2) { create(:entity_person) } }
      let(:person) { people.first }
      it "only shows pagination limit number of interlocks per page" do
        expect(person.interlocks.size).to eq Entity::PER_PAGE
      end

      it "shows the correct page" do
        expect(person.interlocks(2).size).to eql 1
      end
    end
  end

  context "for an org" do
    let(:orgs) { Array.new(4) { create(:entity_org) } }
    let(:org) { orgs.first }
    let(:people) { Array.new(3) { create(:entity_person) } }

    before { interlock_orgs_via_people(orgs, people) }

    context "with less interlocks than pagination limit" do

      it "lists all orgs with common staff or owners" do
        expect(org.interlocks.to_a)
          .to eql([
                    {
                      "connected_entity" => orgs[3],
                      "connecting_entities" => people.take(3)
                    },
                    {
                      "connected_entity" => orgs[2],
                      "connecting_entities" => people.take(2)
                    },
                    {
                      "connected_entity" => orgs[1],
                      "connecting_entities" => people.take(1)
                    }
                  ])
      end
    end
  end
end
