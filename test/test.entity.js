describe('Entity.js', function(){
  describe('political', function(){
    describe('parseContributions', function(){
      it('calculates amount per cycle', function(){
        var contributions = [
          {cycle: '2014', amount: 1000},
          {cycle: '2010', amount: 400},
          {cycle: '1998', amount: 100}, 
          {cycle: '2010', amount: 200}, 
        ];
        var parsed = entity.political.parseContributions(contributions);
        expect(parsed).to.be.a('Array');
        expect(parsed).to.have.lengthOf(14);
        expect(parsed[0]).to.eql({year: '1990', amount: 0});
        expect(parsed[1]).to.eql({year: '1992', amount: 0});
        expect(parsed[13]).to.eql({ year: '2016', amount: 0});
        expect(parsed[12]).to.eql({year: '2014', amount: 1000});
        expect(parsed[10]).to.eql({year: '2010', amount: 600});
      });
    });
  });
});
 
