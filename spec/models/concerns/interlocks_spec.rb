require "rails_helper"

describe 'Entity: Interlocks', :interlocks_helper, :pagination_helper, type: :model do

  context "for a person" do
    let(:people) { Array.new(4) { create(:entity_person) } }
    let(:person) { people.first }
    let(:orgs) { Array.new(3) { create(:entity_org) } }
    before { interlock_people_via_orgs(people, orgs) }

    subject { person.interlocks.to_a }

    context "with less than #{Entity::PER_PAGE} interlocks" do
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
end
