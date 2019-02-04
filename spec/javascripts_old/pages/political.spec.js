describe('political', function(){
  var contributions = [
    {cycle: '2014', amount: 1000, "recipcode":"DW", recip_id: 1, recip_name: 'A', recip_ext: 'Person', recip_blurb: null, donor_id: 1, donor_name: 'xyz'},
    {cycle: '2014', amount: 500, "recipcode":"RL", recip_id: 2, recip_name: 'B', recip_ext: 'Person', recip_blurb: null, donor_id: 1, donor_name: 'xyz'},
    {cycle: '2010', amount: 400, "recipcode":"DW", recip_id: 10, recip_name: 'C', recip_ext: 'Org', recip_blurb: null, donor_id: 1, donor_name: 'xyz'},
    {cycle: '1998', amount: 100, "recipcode":"DW", recip_id: 1, recip_name: 'A', recip_ext: 'Person', recip_blurb: null, donor_id: 1, donor_name: 'xyz'}, 
    {cycle: '2010', amount: 200, "recipcode":"DW", recip_id: 10, recip_name: 'C', recip_ext: 'Org', recip_blurb: null, donor_id: 2, donor_name: 'abc'}, 
    {cycle: '2008', amount: 800, "recipcode":"XL", recip_id: 15, recip_name: 'D', recip_ext: 'Person', recip_blurb: null, donor_id: 2, donor_name: 'abc'},
  ];
  describe('parseContributions', function(){
    it('calculates amount per cycle', function(){
      var parsed = political.parseContributions(contributions);
      expect(parsed).toBeArray();
      expect(parsed).toBeArrayOfSize(14);
      expect(parsed[0]).toEqual({year: '1990', amount: 0, dem: 0, gop: 0, other: 0, pac: 0, out: 0});
      expect(parsed[1]).toEqual({year: '1992', amount: 0, dem: 0, gop: 0, other: 0, pac: 0, out: 0});
      expect(parsed[13]).toEqual({year: '2016', amount: 0, dem: 0, gop: 0, other: 0, pac: 0, out: 0});
      expect(parsed[12]).toEqual({year: '2014', amount: 1500, dem: 1000, gop: 500, other: 0, pac: 0, out: 0});
      expect(parsed[10]).toEqual({year: '2010', amount: 600, dem: 600, gop: 0, other: 0, pac: 0, out: 0});
      expect(parsed[9]).toEqual({year: '2008', amount: 800, dem: 0, gop: 0, other: 800, pac: 0, out: 0});
    });
  });

  describe('contributionAggregate(): groups and sums contributions by party', function(){
      var parsed = political.parseContributions(contributions);
      var aggregated = political.contributionAggregate(parsed);
      it('returns an array with 5 objects', function(){
        expect(aggregated).toBeArrayOfSize(5);
        aggregated.forEach(function(x){
          expect(x).toBeObject();
        });
      });
      it('contains parties in this order: D, R, P, I, O', function(){
        expect(aggregated[0].party).toEqual('D');
        expect(aggregated[1].party).toEqual('R');
        expect(aggregated[2].party).toEqual('P');
        expect(aggregated[3].party).toEqual('I');
        expect(aggregated[4].party).toEqual('O');
      });
      it('calculates correct amount', function(){
        expect(aggregated[0].amount).toEqual(1700);
        expect(aggregated[1].amount).toEqual(500);
        expect(aggregated[2].amount).toEqual(0);
        expect(aggregated[3].amount).toEqual(800);
        expect(aggregated[4].amount).toEqual(0);
      });
    });
  describe('groupByRecip(): ', function(){
      describe('filter by Person', function(){
        var groupBy = political.groupByRecip(contributions, 'Person');

        it('return an array with 3 objects', function(){
          expect(groupBy).toBeArray();
          expect(groupBy).toBeArrayOfSize(3);
          groupBy.forEach( x => expect(x).toBeObject() );
        });

        it('each object\'s "value" has the correct keys', function(){
          groupBy.forEach( x => {
            // expect(x.value).to.include.keys('amount');
            // expect(x.value).to.include.keys('name');
            // expect(x.value).to.include.keys('blurb');
            // expect(x.value).to.include.keys('ext');
            // expect(x.value.ext).toEqual('Person');
            // expect(x.value).to.include.keys('count');
            expect(x.value).toHaveMember('amount');
            expect(x.value).toHaveMember('name');
            expect(x.value).toHaveMember('blurb');
            expect(x.value).toHaveMember('ext');
            expect(x.value.ext).toEqual('Person');
            expect(x.value).toHaveMember('count');
          });
        });
        
        it('calculates sum per recipient and sorts', function(){
          expect(groupBy.map(x => x.value.amount)).toEqual([1100,800,500]);
        });
      });

      describe('filter by org', function(){
        var groupBy = political.groupByRecip(contributions, 'Org');

        it('return an array with 1 objects', function(){
	  expect(groupBy).toBeArray();
          expect(groupBy).toBeArrayOfSize(1);
          groupBy.forEach( x => expect(x).toBeObject() );
        });

        it('each object\'s "value" has the correct keys', function(){
          groupBy.forEach( x => {
            expect(x.value).toHaveMember('amount');
            expect(x.value).toHaveMember('name');
            expect(x.value).toHaveMember('blurb');
            expect(x.value).toHaveMember('ext');
            expect(x.value.ext).toEqual('Org');
            expect(x.value).toHaveMember('count');
          });
        });
        
        it('calculates sum per recipient and sorts', function(){
          expect(groupBy.map(x => x.value.amount)).toEqual([600]);
        });
      });

      describe('no filter', function(){
        var groupBy = political.groupByRecip(contributions);

        it('return an array with 4 objects', function(){
          expect(groupBy).toBeArray();
          expect(groupBy).toBeArrayOfSize(4);
          groupBy.forEach( x => expect(x).toBeObject() );
        });

        it('each object\'s "value" has the correct keys', function(){
          groupBy.forEach( x => {
            expect(x.value).toHaveMember('amount');
            expect(x.value).toHaveMember('name');
            expect(x.value).toHaveMember('blurb');
            expect(x.value).toHaveMember('ext');
            expect(x.value).toHaveMember('count');
          });
        });

        it('calculates sum per recipient and sorts', function(){
          expect(groupBy.map(x => x.value.amount)).toEqual([1100,800,600,500]);
          expect(groupBy.map(x => x.value.ext)).toEqual(['Person','Person','Org','Person']);
        });
      });
  });
  describe('groupByDonor()', function(){
    // donor_id 1 amount -> 2000, donor_id 2 amount -> 1000
    var groupByDonor = political.groupByDonor(contributions);
    xit('groups donors by id and sums up amount', function() {
      //console.log(groupByDonor);
      expect(groupByDonor).toEqual([
	{key: '1', value: { name: 'xyz', amount: 2000, pct: (2000 / 3000 * 100)}  },
	{key: '2', value: { name: 'abc', amount: 1000, pct: (1000 / 3000 * 100)} },
      ]);
    });

    it('if more than 7 donors are present, it sums the rest into an aggregate', function(){
      var more_than_7_contributions = [
	{amount: 1, donor_id: 1, donor_name: 'one'},
	{amount: 1, donor_id: 2, donor_name: 'two'},
	{amount: 1, donor_id: 3, donor_name: 'three'},
	{amount: 1, donor_id: 4, donor_name: 'four'},
	{amount: 1, donor_id: 5, donor_name: 'five'},
	{amount: 1, donor_id: 6, donor_name: 'six'},
	{amount: 1, donor_id: 7, donor_name: 'seven'},
	{amount: 1, donor_id: 8, donor_name: 'eight'},
	{amount: 1, donor_id: 9, donor_name: 'nine'},
      ];

      var groupByDonor = political.groupByDonor(more_than_7_contributions);
      expect(groupByDonor.length).toEqual(8);
      expect(groupByDonor[0]).toEqual({key: '1', value: { name: 'one', amount: 1, pct: (1 / 9)}  });
      expect(groupByDonor[7]).toEqual({key: 'rest', value: { name: 'others', amount: 2, pct: (2 / 9)}  });
    });
  });

});
