describe LinksGroup do
  context 'with generic links' do
    before  do
      rel1 = build(:generic_relationship, entity1_id: 10, entity2_id: 20)
      rel2 = build(:generic_relationship, entity1_id: 10, entity2_id: 50)
      @link1 = build(:link, entity1_id: 10, entity2_id: 20, relationship: rel1, category_id: 12)
      @link2 = build(:link, entity1_id: 10, entity2_id: 50, relationship: rel2, category_id: 12)
      @links_group = LinksGroup.new([@link1, @link2], 'miscellaneous', 'Other Affiliations')
    end

    it 'sets keybord, heading and category_id' do
      expect(@links_group.keyword).to eq 'miscellaneous'
      expect(@links_group.heading).to eq 'Other Affiliations'
      expect(@links_group.category_id).to eq 12
    end

    it 'has correct count' do
      expect(@links_group.count).to eq 2
    end

    it 'links is a nested array' do
      expect(@links_group.links).to be_a(Array)
      expect(@links_group.links[0]).to be_a(Array)
      expect(@links_group.links[0][0]).to be_a(Link)
    end

    it 'orders the data in the default order' do
      expect(@links_group.links).to eq [[@link2], [@link1]]
    end
  end

  context 'with donation links' do
    before do
      e1_id = 1000
      rel1 = build(:donation_relationship, entity1_id: e1_id, entity2_id: 2000, amount: 10)
      rel2 = build(:donation_relationship, entity1_id: e1_id, entity2_id: 3000, amount: 30)
      rel3 = build(:donation_relationship, entity1_id: e1_id, entity2_id: 3000, amount: 20)
      @link1 = build(:link, entity1_id: e1_id, entity2_id: 2000, relationship: rel1, category_id: 5)
      @link2 = build(:link, entity1_id: e1_id, entity2_id: 3000, relationship: rel2, category_id: 5)
      @link3 = build(:link, entity1_id: e1_id, entity2_id: 3000, relationship: rel3, category_id: 5)
      @links_group = LinksGroup.new([@link1, @link2, @link3],  'donation_recipients', 'Donation/Grant Recipients')
    end

    it 'has correct count' do
      expect(@links_group.count).to eq 2
    end

    it 'order links by amount' do
      expect(@links_group.links).to eq [[@link2,@link3], [@link1]]
    end
  end

  describe 'link sorting' do
    let(:org) { create(:entity_org).add_extension('Business') }
    let(:person) { create(:entity_person) }
    let(:links) { SortedLinks.new(person) }
    let(:links_group) { links.send(:business_positions) }

    before do
      create(:position_relationship, entity: person, related: org, start_date: '2009-01-23', end_date: '2010-01-01')
      create(:position_relationship, entity: person, related: org, start_date: '2010-10-01', end_date: '2011-10-01')
      create(:position_relationship, entity: person, related: org, start_date: '2013-11-01', end_date: '2019-10-01')
    end

    it 'returns the links at the second level of a two-dimentional array' do
      expect(links_group.links).to be_a Array
      expect(links_group.links.count).to be 1
      expect(links_group.links[0]).to be_a Array
      expect(links_group.links[0].count).to be 3
    end

    context 'with multiple links to the same entity' do
      it 'sorts the links by date' do
        expect(links_group.links[0].map { |l| l.relationship.start_date })
          .to match %w[2013-11-01 2010-10-01 2009-01-23]
      end
    end

    context 'with an older but still-current link' do
      before do
        create(:position_relationship, entity: person, related: org, start_date: '2000-04-18', end_date: nil)
      end

      it 'sorts the links by date' do
        expect(links_group.links[0].map { |l| l.relationship.start_date })
          .to match %w[2000-04-18 2013-11-01 2010-10-01 2009-01-23]
      end
    end

    context 'with a date-less link' do
      before do
        create(:position_relationship, entity: person, related: org, start_date: nil, updated_at: '2020-05-10')
        create(:position_relationship, entity: person, related: org, start_date: '2019-10-01')
      end

      it "doesn't raise an exception" do
        expect { links_group.links }.not_to raise_error
      end

      it 'sorts by updated timestamp instead' do
        expect(links_group.links[0].map { |l| l.relationship.start_date })
          .to match [nil, '2019-10-01', '2013-11-01', '2010-10-01', '2009-01-23']
      end
    end
  end
end
