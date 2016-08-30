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
        expect(parsed[0]).to.eql({year: '1990', amount: 0, dem: 0, gop: 0, other: 0, pac: 0, out: 0});
        expect(parsed[1]).to.eql({year: '1992', amount: 0, dem: 0, gop: 0, other: 0, pac: 0, out: 0});
        expect(parsed[13]).to.eql({year: '2016', amount: 0, dem: 0, gop: 0, other: 0, pac: 0, out: 0});
        expect(parsed[12]).to.eql({year: '2014', amount: 1500, dem: 1000, gop: 500, other: 0, pac: 0, out: 0});
        expect(parsed[10]).to.eql({year: '2010', amount: 600, dem: 600, gop: 0, other: 0, pac: 0, out: 0});
        expect(parsed[9]).to.eql({year: '2008', amount: 800, dem: 0, gop: 0, other: 800, pac: 0, out: 0});
      });
    });
    describe('contributionAggregate(): groups and sums contributions by party', function(){
      var parsed = entity.political.parseContributions(contributions);
      var aggregated = entity.political.contributionAggregate(parsed);
      it('returns an array with 5 objects', function(){
        expect(aggregated).to.have.lengthOf(5);
        aggregated.forEach(function(x){
          expect(x).to.be.a('Object');
        });
      });
      it('contains parties in this order: D, R, P, I, O', function(){
        expect(aggregated[0].party).to.eql('D');
        expect(aggregated[1].party).to.eql('R');
        expect(aggregated[2].party).to.eql('P');
        expect(aggregated[3].party).to.eql('I');
        expect(aggregated[4].party).to.eql('O');
      });
      it('calculates correct amount', function(){
        expect(aggregated[0].amount).to.eql(1700);
        expect(aggregated[1].amount).to.eql(500);
        expect(aggregated[2].amount).to.eql(0);
        expect(aggregated[3].amount).to.eql(800);
        expect(aggregated[4].amount).to.eql(0);
      });
    });

    describe('groupByRecip(): ', function(){
      describe('filter by Person', function(){
        var groupBy = entity.political.groupByRecip(contributions, 'Person');

        it('return an array with 3 objects', function(){
          expect(groupBy).to.be.an('array');
          expect(groupBy).to.have.lengthOf(3);
          groupBy.forEach( x => expect(x).to.be.an('object') );
        });

        it('each object\'s "value" has the correct keys', function(){
          groupBy.forEach( x => {
            expect(x.value).to.include.keys('amount');
            expect(x.value).to.include.keys('name');
            expect(x.value).to.include.keys('blurb');
            expect(x.value).to.include.keys('ext');
            expect(x.value.ext).to.eql('Person');
            expect(x.value).to.include.keys('count');
          });
        });
        
        it('calculates sum per recipient and sorts', function(){
          expect(groupBy.map(x => x.value.amount)).to.eql([1100,800,500]);
        });
      });

      describe('filter by org', function(){
        var groupBy = entity.political.groupByRecip(contributions, 'Org');

        it('return an array with 1 objects', function(){
          expect(groupBy).to.be.an('array');
          expect(groupBy).to.have.lengthOf(1);
          groupBy.forEach( x => expect(x).to.be.an('object') );
        });

        it('each object\'s "value" has the correct keys', function(){
          groupBy.forEach( x => {
            expect(x.value).to.include.keys('amount');
            expect(x.value).to.include.keys('name');
            expect(x.value).to.include.keys('blurb');
            expect(x.value).to.include.keys('ext');
            expect(x.value.ext).to.eql('Org');
            expect(x.value).to.include.keys('count');
          });
        });
        
        it('calculates sum per recipient and sorts', function(){
          expect(groupBy.map(x => x.value.amount)).to.eql([600]);
        });
      });

      describe('no filter', function(){
        var groupBy = entity.political.groupByRecip(contributions);

        it('return an array with 4 objects', function(){
          expect(groupBy).to.be.an('array');
          expect(groupBy).to.have.lengthOf(4);
          groupBy.forEach( x => expect(x).to.be.an('object') );
        });

        it('each object\'s "value" has the correct keys', function(){
          groupBy.forEach( x => {
            expect(x.value).to.include.keys('amount');
            expect(x.value).to.include.keys('name');
            expect(x.value).to.include.keys('blurb');
            expect(x.value).to.include.keys('ext');
            expect(x.value).to.include.keys('count');
          });
        });

        it('calculates sum per recipient and sorts', function(){
          expect(groupBy.map(x => x.value.amount)).to.eql([1100,800,600,500]);
          expect(groupBy.map(x => x.value.ext)).to.eql(['Person','Person','Org','Person']);
        });
      });

    });

  });
});
