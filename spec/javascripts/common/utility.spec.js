describe('utility', function(){
  describe('range', function() {
    it('returns range', function() {
      expect(utility.range(3)).toEqual([0,1,2]);
    });
    it('can optionally exclude numbers', function() {
      expect(utility.range(4, [1,2])).toEqual([0,3]);
    });
  });
  describe('RelationshipDetails', function(){
    it('returns an nested array', function(){
      utility.range(13, [7]).slice(1).forEach( i => {
	var details = utility.relationshipDetails(i);
	expect(details).toBeArray();
	details.forEach( x => expect(x).toBeArray());
	details.forEach( detail => {
	  expect(detail.length).toEqual(3);
	  detail.forEach( x => expect(x).toBeString());
	});
      });
    });
    it('throws errors if not between 1-12 and not 7', function(){
      utility.range(13, [0, 7]).forEach( i => {
	expect(() => utility.relationshipDetails(i)).not.toThrow(Error);
      });
      expect(() => utility.relationshipDetails(7)).toThrow('Lobbying relationships are not currently supposed by the bulk add tool');
      var invalidMsg = "Invalid relationship category. It must be a number between 1 and 12";
      expect(() => utility.relationshipDetails(0)).toThrow(invalidMsg);
      expect(() => utility.relationshipDetails(13)).toThrow(invalidMsg);
    });
  });

  describe('validDate', function() {
    it('works with good dates', function() {
      ['2016-01-01', '1992-12-03'].map(utility.validDate).forEach( d => expect(d).toBeTrue() );
    });

    it('works with bad dates', function() {
      ['tuesday', '20000-01-01', '1888-01', '1999-13-02', '2000-01-50']
	.map(utility.validDate).forEach( d => expect(d).toBeFalse() );
    });
  });

  describe('validURL', function(){
    it('accepts simple urls', function(){
      expect(utility.validURL('https://simple.url')).toBeTrue();
    });

    it('rejects bad urls', function(){
      expect(utility.validURL('/not/a/url')).toBeFalse();
    });
  });

  describe('object utilities', () => {

    const obj = { a: 1, b: 2};

    describe('#getProperty', () => {
      it('reads an arbitrary key from an object', () => {
        expect(utility.getProperty(obj, 'a')).toEqual(1);
      });
    });

    describe('#setProperty', () => {
      it('sets the value for an arbitary key on an object', () => {
        expect(utility.setProperty(obj, 'c', 3)).toEqual({ a: 1, b: 2, c: 3 });
      });

      it('allows the value for key to be subsequently mutated', () => {
        const _obj = utility.setProperty(obj, 'c', 3);
        utility.setProperty(_obj, 'c', 4);
        expect(_obj.c).toEqual(4);
      });
    });

    describe('#isEmpty', () => {
      it("discovers if an object is empty", () => {
        expect(utility.isEmpty(obj)).toEqual(false);
        expect(utility.isEmpty({})).toEqual(true);
      });

      it('discovers if an array is empty', () => {
        expect(utility.isEmpty([])).toEqual(true);
        expect(utility.isEmpty([1, 2])).toEqual(false);
      });
    });
  });
});
