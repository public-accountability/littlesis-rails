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

  describe('validation utilities', () => {

    describe('#validDate', function() {

      it('works with good dates', function() {
        ['2016-01-01', '1992-12-03'].map(utility.validDate).forEach( d => expect(d).toBeTrue() );
      });

      it('works with bad dates', function() {
        ['tuesday', '20000-01-01', '1888-01', '1999-13-02', '2000-01-50']
	  .map(utility.validDate).forEach( d => expect(d).toBeFalse() );
      });
    });

    describe('#validURL', function(){

      it('accepts simple urls', function(){
        expect(utility.validURL('https://simple.url')).toBeTrue();
      });

      it('rejects bad urls', function(){
        expect(utility.validURL('/not/a/url')).toBeFalse();
      });
    });

    describe('#validPersonName', () => {

      it('requires a first and last name', () => {
        expect(utility.validPersonName('Oedipa')).toBeFalse();
        expect(utility.validPersonName('Oedipa Maas')).toBeTrue();
      });

      it('rejects numerical characters', () => {
        expect(utility.validPersonName('03d1p4 M445')).toBeFalse();
      });

      it('allows lower case names', () => {
        expect(utility.validPersonName('oedipa maas')).toBeTrue();
      });

      it('allows hyphenated names', () => {
        expect(utility.validPersonName('Oedipa-Wendell Mucho-Maas')).toBeTrue();
      });

      it('allows prefixes and suffixes', () => {
        expect(utility.validPersonName('Mrs. Oedipa Maas, Sr.')).toBeTrue();
        expect(utility.validPersonName('Mr. Wendell Maas, III')).toBeTrue();
      });

      it('allows non-english unicode code points', () => {
        expect(utility.validPersonName('OedìpⒶ Måăß 겫겫겫')).toBeTrue();
      });

      it('allows very short names', () => {
        expect(utility.validPersonName('W. A. S. T. E.')).toBeTrue();
      });

      it('allows up to 5 names', () => {
        expect(utility.validPersonName('trystero trystero trystero trystero trystero')).toBeTrue();
      });
    });
  });

  describe('string utilities', () => {

    describe('#capitalize', () => {

      it('capitalizes a string', () => {
        expect(utility.capitalize("foobar")).toEqual("Foobar");
      });
    });
  });

  describe('object utilities', () => {

    const obj = { a: 1, b: 2};

    
    describe('#get', () => {
      it('reads an arbitrary key from an object', () => {
        expect(utility.get(obj, 'a')).toEqual(1);
      });

      it('handles non-existent properties', () => {
        expect(utility.get(obj, "foo")).toEqual(undefined);
      });

      it('handles null objects', () => {
        expect(utility.get(null, "foo")).toEqual(undefined);
      });

      it('handles undefined objects', () => {
        expect(utility.get(undefined, "foo")).toEqual(undefined);
      });
    });

    describe('#set', () => {
      it('sets the value for an arbitary key on an object', () => {
        expect(utility.set(obj, 'c', 3)).toEqual({ a: 1, b: 2, c: 3 });
      });

      it('does not mutate objects', () => {
        utility.set(obj, 'c', 3);
        expect(obj).toEqual({ a: 1, b: 2});
      });

      it('does not allow newly created entries to be mutated', () => {
        const _obj = utility.set(obj, 'c', 3);
        _obj.c = 4;
        expect(_obj.c).toEqual(3);
      });

      it('does allow newly created entries to be re-set', () => {
        const _obj = utility.set(obj, 'c', 3);
        const __obj = utility.set(_obj, 'c', 4);
        expect(__obj.c).toEqual(4);
      });
    });

    describe('#delete', () => {

      it('removes an entry from an object', () => {
        expect(utility.delete(obj, 'a')).toEqual({ b: 2 });
      });
    });

    const nestedObj = { a: { b: 2, c: 3 } };

    describe('#deleteIn', () => {

      it('removes a nested entry from an object', () => {
        expect(utility.deleteIn(nestedObj, ['a', 'b']))
          .toEqual({ a: { c: 3 } });
      });
    });
    
    describe('#getIn', () => {

      it('reads values from a nested sequence of keys in an object', () => {
        expect(utility.getIn(nestedObj, ["a", "b"])).toEqual(2);
      });

      it('handles non-existent nested keys', () => {
        expect(utility.getIn(nestedObj, ["a", "foo"])).toEqual(undefined);
      });

      it('handles lookup sequences that are longer than depth of object tree', () => {
        expect(utility.getIn(nestedObj, ["a", "b", "d"])).toEqual(undefined);
      });
    });

    describe('#setIn', () => {

      it('sets the value for a nested key in an object', () => {
        expect(utility.setIn(nestedObj, ['a', 'b'], 4))
          .toEqual({ a: { b: 4, c: 3 } });
      });

      it('creates and sets the value for a nested key in an object', () => {
        expect(utility.setIn(nestedObj, ['a', 'd'], 4))
          .toEqual({ a: { b: 2, c: 3, d: 4 } });
      });

      it("handles paths longer than tree", () => {
        expect(utility.setIn(nestedObj, ["a", "d", "e"], 4))
          .toEqual({ a: { b: 2, c: 3, d: { e: 4 } } });
      });

      it('handles wierd paths', () => {
        expect(utility.setIn(nestedObj, ['a', 'b', 'c'], 4))
          .toEqual({ a: { b: { c: 4}, c: 3 } } );
      });
    });

    describe("#pick", () => {
      it('returns object with a permitted set of keys', () => {
	var obj = { a: 1, b: 2, c: 3 };
	expect(utility.pick(obj, ['a', 'c']))
	  .toEqual({ a: 1, c: 3 });
      });
    });
    
    describe("#omit", () => {
      it('returns object without rejected set of keys', () => {
	var obj = { a: 1, b: 2, c: 3 };
	expect(utility.omit(obj, ['a', 'c']))
	  .toEqual({ b: 2 });
      });
    });

    describe('#isObject', () => {

      it('returns true for an object', () => {
        expect(utility.isObject({})).toBeTrue();
      });

      it('returns true for a function', () => {
        expect(utility.isObject(() => 'foo')).toBeTrue();
      });

      it('returns false for a string', () => {
        expect(utility.isObject('foo')).toBeFalse();
        expect(utility.isObject('')).toBeFalse();
      });

      it('returns false for a boolean', () => {
        expect(utility.isObject(true)).toBeFalse();
        expect(utility.isObject(false)).toBeFalse();
      });

      it('returns false for null', () => {
        expect(utility.isObject(null)).toBeFalse();
      });

      it('returns false for undefined', () => {
        expect(utility.isObject(undefined)).toBeFalse();
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

    describe('#exists', () => {
      it('returns true if an object exists, false otherwise', () => {
        expect(utility.exists(0)).toBeTrue();// thanks ES5, for making me write a func just for this corner case!
        expect(utility.exists(undefined)).toBeFalse();
        expect(utility.exists(null)).toBeFalse();
      });
    });
    
    describe('#normalize', () => {

      it('transforms an array of resources into a lookup table of resources by id', () => {
        expect(utility.normalize(
          [
            { id: 'a', foo: 'bar' },
            { id: 'b', foo: 'bar' }
          ]
        )).toEqual(
          {
            a: { id: 'a', foo: 'bar' },
            b: { id: 'b', foo: 'bar' }
          }
        );
      });
    });
  });

  describe('DOM utilities', () => {

    const testDom ='<div id="test-dom"></div>';
    beforeEach(() => $('body').append(testDom));
    afterEach(() => $('#test-dom').remove());

    describe('#appendSpinner', () => {

      it('appends a spinner to a DOM node', () => {
        utility.appendSpinner($('#test-dom'));
        expect($('#test-dom .sk-circle')).toExist();
      });
    });

    describe('#removeSpinner', () => {

      it('removes a spinner from a DOM node', () => {
        utility.appendSpinner($('#test-dom'));
        utility.removeSpinner($('#test-dom'));
        expect($('#test-dom .sk-circle')).not.toExist();
      });
    });

    describe('#createElementWithText', () => {
      it('creates a new element', () => {
	document.getElementById('test-dom')
	  .appendChild( utility.createElementWithText('p', 'just a simple paragraph'));

	expect( $('#test-dom > p').text() ).toEqual('just a simple paragraph');
      });
    });

    describe('#createLink', () => {
      it('creates a new link', () => {
	document.getElementById('test-dom')
	  .appendChild( utility.createLink('https://example.com/'));

	var link = $('#test-dom > a')[0];
	expect( link['href']).toEqual('https://example.com/');
	expect( link.text).toEqual('');
      });

      it('can creates a new link with text', () => {
	document.getElementById('test-dom')
	  .appendChild( utility.createLink('https://example.com/', 'a website'));

	var link = $('#test-dom > a')[0];
	expect( link['href']).toEqual('https://example.com/');
	expect( link.text).toEqual('a website');
      });
    });

    describe('#createElement', () => {
      it('defaults to div', () => {
	document.getElementById('test-dom').appendChild(utility.createElement());
	expect( $('#test-dom > div').length ).toEqual(1);
      });

      it('can be initalized with a class', () => {
	document.getElementById('test-dom')
	  .appendChild(utility.createElement({ "tag": 'span', "class": 'one two'}));
	expect($('#test-dom > span.one.two')).toExist();
      });

      it('can be initalized with an id', () => {
	document.getElementById('test-dom')
	  .appendChild(utility.createElement({ "id": 'foolsGold'}));
	expect($('#foolsGold')).toExist();
      });

      it('can be create element with text', () => {
	document.getElementById('test-dom')
	  .appendChild(utility.createElement({ "id": 'example', "tag": 'span', "text": 'example' }));

	expect(document.getElementById('example').textContent).toEqual('example');
      });
    });
  });
});
