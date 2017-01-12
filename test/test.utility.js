describe('utility', function(){
  describe('range', function() {
    it('returns range', function() {
      expect(utility.range(3)).to.eql([0,1,2]);
    });
    it('can optionally exclude numbers', function() {
      expect(utility.range(4, [1,2])).to.eql([0,3]);
    });
  });

  describe('RelationshipDetails', function(){
    it('returns an nested array', function(){
      utility.range(13, [7]).slice(1).forEach( i => {
	var details = utility.relationshipDetails(i);
	expect(details).to.be.instanceof(Array);
	details.forEach( x => expect(x).to.be.instanceof(Array));
	details.forEach( detail => {
	  expect(detail.length).eql(3);
	  detail.forEach( x => expect(x).to.be.a('string'));
	});
      });
    });
    it('throws errors if not between 1-12 and not 7', function(){
      utility.range(13, [0, 7]).forEach( i => {
	expect(() => utility.relationshipDetails(i)).to.not.throw(Error);
      });
      expect(() => utility.relationshipDetails(7)).to.throw(/Lobbying/);
      expect(() => utility.relationshipDetails(0)).to.throw(/Invalid relationship/);
      expect(() => utility.relationshipDetails(13)).to.throw(/Invalid relationship/);
    });
  });

  describe('validDate', function() {

    it('works with good dates', function() {
      ['2016-01-01', '1992-12-03'].map(utility.validDate).forEach( d => expect(d).to.be.true );
    });

    it('works with bad dates', function() {
      ['tuesday', '20000-01-01', '1888-01', '1999-13-02', '2000-01-50']
	.map(utility.validDate).forEach( d => expect(d).to.be.false );
    });

  });
});
