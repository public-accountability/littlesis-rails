describe('Entity.js', function(){
  describe('political', function(){
    var contributions = [
      {cycle: '2014', amount: 1000, "recipcode":"DW"},
      {cycle: '2014', amount: 500, "recipcode":"RL"},
      {cycle: '2010', amount: 400, "recipcode":"DW"},
      {cycle: '1998', amount: 100, "recipcode":"DW"}, 
      {cycle: '2010', amount: 200, "recipcode":"DW"}, 
      {cycle: '2008', amount: 800, "recipcode":"XL"}, 
    ];
    describe('parseContributions', function(){
      it('calculates amount per cycle', function(){
        var parsed = entity.political.parseContributions(contributions);
        console.log(JSON.stringify(parsed));
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
    describe('contributionAggregate', function(){
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
  });
});
 
