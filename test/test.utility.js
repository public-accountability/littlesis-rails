describe('utility', function(){
  describe('range', function() {
    it('returns range', function() {
      expect(utility.range(3)).to.eql([0,1,2]);
    });
    it('can optionally exclude numbers', function() {
      expect(utility.range(4, [1,2])).to.eql([0,3]);
    });
  });
});
