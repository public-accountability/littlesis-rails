describe('Entity.js', function(){
  describe('political', function(){
    var contributions = [
      {cycle: '2014', amount: 1000, "recipcode":"DW", recip_id: 1, recip_name: 'A', recip_ext: 'Person', recip_blurb: null},
      {cycle: '2014', amount: 500, "recipcode":"RL", recip_id: 2, recip_name: 'B', recip_ext: 'Person', recip_blurb: null},
      {cycle: '2010', amount: 400, "recipcode":"DW", recip_id: 10, recip_name: 'C', recip_ext: 'Org', recip_blurb: null},
      {cycle: '1998', amount: 100, "recipcode":"DW", recip_id: 1, recip_name: 'A', recip_ext: 'Person', recip_blurb: null}, 
      {cycle: '2010', amount: 200, "recipcode":"DW", recip_id: 10, recip_name: 'C', recip_ext: 'Org', recip_blurb: null}, 
      {cycle: '2008', amount: 800, "recipcode":"XL", recip_id: 15, recip_name: 'D', recip_ext: 'Person', recip_blurb: null}, 
    ];
    describe('parseContributions', function(){
      it('calculates amount per cycle', function(){
        var parsed = entity.political.parseContributions(contributions);
        expect(parsed).to.be.a('Array');
        expect(parsed).to.have.lengthOf(14);
        expect(parsed[0]).to.eql({year: '1990', amount: 0, dem: 0, gop: 0, other: 0});
        expect(parsed[1]).to.eql({year: '1992', amount: 0, dem: 0, gop: 0, other: 0});
        expect(parsed[13]).to.eql({year: '2016', amount: 0, dem: 0, gop: 0, other: 0});
        expect(parsed[12]).to.eql({year: '2014', amount: 1500, dem: 1000, gop: 500, other: 0});
        expect(parsed[10]).to.eql({year: '2010', amount: 600, dem: 600, gop: 0, other: 0});
        expect(parsed[9]).to.eql({year: '2008', amount: 800, dem: 0, gop: 0, other: 800});
      });
    });
    describe('contributionAggregate(): groups and sums contributions by party', function(){
      var parsed = entity.political.parseContributions(contributions);
      var aggregated = entity.political.contributionAggregate(parsed);
      it('returns an array with 3 objects', function(){
        expect(aggregated).to.have.lengthOf(3);
        aggregated.forEach(function(x){
          expect(x).to.be.a('Object');
        });
      });
      it('contains parties in this order: D, R, I', function(){
        expect(aggregated[0].party).to.eql('D');
        expect(aggregated[1].party).to.eql('R');
        expect(aggregated[2].party).to.eql('I');
      });
      it('calculates correct amount', function(){
        expect(aggregated[0].amount).to.eql(1700);
        expect(aggregated[1].amount).to.eql(500);
        expect(aggregated[2].amount).to.eql(800);
      });
    });
    describe('groupByRecip(): recipient and type', function(){
      var groupBy = entity.political.groupByRecip(contributions, true);
      it('returns an array with 2 object with keys: "Org"", and "Person"', function(){
        expect(groupBy).to.be.an('array');
        expect(groupBy).to.have.lengthOf(2);
        expect(groupBy[0].key).to.eql('Org');
        expect(groupBy[1].key).to.eql('Person');
      });

      it('groups orgs together and calculates sum', function(){
        expect(groupBy[0].values).to.have.lengthOf(1);
        expect(groupBy[0].values[0].value.amount).to.eql(600);
      });

      it('has name, blurb and count fields', function(){
        expect(groupBy[0].values[0].value.count).to.eql(2);
        expect(groupBy[0].values[0].value.name).to.eql('C');
        expect(groupBy[0].values[0].value.blurb).to.eql(null);
        expect(groupBy[1].values[0].value.count).to.eql(2);
        expect(groupBy[1].values[1].value.count).to.eql(1);
        expect(groupBy[1].values[2].value.count).to.eql(1);
        expect(groupBy[1].values[0].value.name).to.eql('A');
        expect(groupBy[1].values[0].value.blurb).to.eql(null);
      });
      
      function amountForX(x){
        return groupBy[1].values.find( d => d.key === x).value.amount;
      }

      it('groups politicians together and calculates sum', function(){
        expect(groupBy[1].values).to.have.lengthOf(3);
        expect(amountForX('1')).to.eql(1100);
        expect(amountForX('2')).to.eql(500);
        expect(amountForX('15')).to.eql(800);
      });
      
      it('sorts by largest amount', function(){
        expect(groupBy[1].values.map( x => x.value.amount)).eql([1100,800,500]);
      });
      
    });
    
    describe('groupByRecip(): recipient only', function(){
      var groupBy = entity.political.groupByRecip(contributions, false);
      
      it('return an array with 4 objects', function(){
        expect(groupBy).to.be.an('array');
        expect(groupBy).to.have.lengthOf(4);
        groupBy.forEach( x => expect(x).to.be.an('object') );
      });
      
      it('calculates sum per recipient and sorts', function(){
        expect(groupBy.map(x => x.value.amount)).to.eql([1100,800,600,500]);
      });
    });
    
  });
});

