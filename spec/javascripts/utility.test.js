import utility from 'packs/common/utility';

describe('entityLink', () => {
  it('returns link for person', () => {
    expect(utility.entityLink('123', 'jane doe', 'person'))
      .toEqual('https://littlesis.org/person/123-jane_doe');
  });

  it('returns link for org', () => {
    expect(utility.entityLink('456', 'corp INC.', 'org'))
      .toEqual('https://littlesis.org/org/456-corp_INC.');
  });

});

describe('range', () => {
  it('returns range', () => expect(utility.range(3)).toEqual([0,1,2]));
  it('can optionally exclude numbers', () => {
    expect(utility.range(4, [1,2])).toEqual([0,3]);
  });
});


describe('randomDigitStringId', () => {
  it('returns 10 digits by default', () => {
    expect(utility.randomDigitStringId().length).toEqual(10);
  });

  it('can returns number of digits provided by value', () => {
    expect(utility.randomDigitStringId(3).length).toEqual(3);
  });

  it('raises error if given more than 14 digits', () => {
    expect(() => utility.randomDigitStringId(15)).toThrow();
  });
});


describe('entityInfo', () => {
  document.body.innerHTML = '<div id="entity-info" data-foo="bar"><div/>';
  expect(utility.entityInfo('foo')).toEqual('bar');
});


describe('relationship constants', () => {
  test('relationshipCategories', () => expect(Array.isArray(utility.relationshipCategories)).toBe(true));
  test('extensionDefinitions', () => expect(typeof utility.extensionDefinitions).toBe('object'));
});

describe('RelationshipDetails', () => {
  it('returns an nested array', () => {
    utility.range(13, [7]).slice(1).forEach( i => {
      const details = utility.relationshipDetails(i);

      expect(Array.isArray(details)).toBe(true);

      details.forEach(detail => {
	expect(Array.isArray(detail)).toBe(true);
	expect(detail).toHaveLength(3);
	detail.forEach(x  => expect(typeof x).toEqual('string'));
      });
    });
  });

  it('throws errors if not between 1-12 and not 7', () => {
    utility.range(13, [0, 7]).forEach( i => {
      expect(() => utility.relationshipDetails(i)).not.toThrow(Error);
    });
    expect(() => utility.relationshipDetails(7)).toThrow('Lobbying relationships are not currently supposed by the bulk add tool');
    const invalidMsg = "Invalid relationship category. It must be a number between 1 and 12";
    expect(() => utility.relationshipDetails(0)).toThrow(invalidMsg);
    expect(() => utility.relationshipDetails(13)).toThrow(invalidMsg);
  });
});


describe('#validDate', function() {
  test('good dates', function() {
    ['1992-12-00', '2016-01-01', '1992-12-03'].map(utility.validDate).forEach( d => expect(d).toBe(true) );
  });

  test('bad dates', function() {
    ['tuesday', '20000-01-01', '1888-01', '1999-13-02', '2000-01-50']
      .map(utility.validDate).forEach( d => expect(d).toBe(false) );
  });
});

describe('#validURL', function(){
  test('simple url', () => expect(utility.validURL('https://simple.url')).toBe(true));
  test('bad url', () => expect(utility.validURL('/not/a/url')).toBe(false));
});

describe('#validPersonName', () => {

  it('requires a first and last name', () => {
    expect(utility.validPersonName('Oedipa')).toBe(false);
    expect(utility.validPersonName('Oedipa Maas')).toBe(true);
  });

  it('rejects numerical characters', () => {
    expect(utility.validPersonName('03d1p4 M445')).toBe(false);
  });

  it('allows lower case names', () => {
    expect(utility.validPersonName('oedipa maas')).toBe(true);
  });

  it('allows hyphenated names', () => {
    expect(utility.validPersonName('Oedipa-Wendell Mucho-Maas')).toBe(true);
  });

  it('allows prefixes and suffixes', () => {
    expect(utility.validPersonName('Mrs. Oedipa Maas, Sr.')).toBe(true);
    expect(utility.validPersonName('Mr. Wendell Maas, III')).toBe(true);
  });

  it('allows non-english unicode code points', () => {
    expect(utility.validPersonName('OedìpⒶ Måăß 겫겫겫')).toBe(true);
  });

  it('allows very short names', () => {
    expect(utility.validPersonName('W. A. S. T. E.')).toBe(true);
  });

  it('allows up to 5 names', () => {
    expect(utility.validPersonName('trystero trystero trystero trystero trystero')).toBe(true);
  });
});

describe('string utilities', () => {
  test('#capitalize', () => expect(utility.capitalize("foobar")).toEqual("Foobar") );

  test('capitalizeWords', ()=> {
    expect(utility.capitalizeWords('foo bar')).toEqual('Foo Bar');
    expect(utility.capitalizeWords('FOO BAR')).toEqual('Foo Bar');
    expect(utility.capitalizeWords('foo bar, llc')).toEqual('Foo Bar, LLC');
  });

  test('formatIdSelector', () => {
    expect(utility.formatIdSelector('foo')).toEqual('#foo');
    expect(utility.formatIdSelector('#foo')).toEqual('#foo');
  });

  test('removeHashFromId', () => {
    expect(utility.removeHashFromId('foo')).toEqual('foo');
    expect(utility.removeHashFromId('#foo')).toEqual('foo');
  });

  test('formatMoney', () => {
    expect(utility.formatMoney('1000')).toEqual('$1,000.00');
    expect(utility.formatMoney('1000', { truncate: true })).toEqual('$1,000');
    expect(utility.formatMoney(100500800.15)).toEqual('$100,500,800.15');
    expect(utility.formatMoney(100500800.15, { truncate: true })).toEqual('$100,500,800');
  });
  
});

describe('object utilities', () => {
  describe('#isObject', () => {

    it('returns true for an object', () => expect(utility.isObject({})).toBe(true));

    it('returns true for a function', () => expect(utility.isObject(() => 'foo')).toBe(true));

    it('returns false for a string', () => {
      expect(utility.isObject('foo')).toBe(false);
      expect(utility.isObject('')).toBe(false);
    });

    it('returns false for a boolean', () => {
      expect(utility.isObject(true)).toBe(false);
      expect(utility.isObject(false)).toBe(false);
    });

    it('returns false for null', () => expect(utility.isObject(null)).toBe(false));
    it('returns false for undefined', () => expect(utility.isObject(undefined)).toBe(false));
  });

  describe('#get', () => {
    const obj = { a: 1, b: 2};
    
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

  describe('#getIn', () => {
    const nestedObj = { a: { b: 2, c: 3 } };
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

  describe('#set', () => {
    const obj = { a: 1, b: 2};
    
    it('sets the value for an arbitary key on an object', () => {
      expect(utility.set(obj, 'c', 3)).toEqual({ a: 1, b: 2, c: 3 });
    });

    it('does not mutate objects', () => {
      utility.set(obj, 'c', 3);
      expect(obj).toEqual({ a: 1, b: 2});
    });

    it('does not allow newly created entries to be mutated', () => {
      let _obj = utility.set(obj, 'c', 3);
      expect(() => _obj.c = 4).toThrowError(/Cannot assign to read only property/);
    });

    it('does allow newly created entries to be re-set', () => {
      const _obj = utility.set(obj, 'c', 3);
      const __obj = utility.set(_obj, 'c', 4);
      expect(__obj.c).toEqual(4);
    });
  });

  describe('#setIn', () => {
    const nestedObj = { a: { b: 2, c: 3 } };
    
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

  describe('#del', () => {
    const obj = { a: 1, b: 2};
    it('removes an entry from an object', () => {
      expect(utility.del(obj, 'a')).toEqual({ b: 2 });
    });
  });

  describe('#deleteIn', () => {
    const nestedObj = { a: { b: 2, c: 3 } };
    it('removes a nested entry from an object', () => {
      expect(utility.deleteIn(nestedObj, ['a', 'b']))
        .toEqual({ a: { c: 3 } });
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

  describe('stringifyValues', () => {
    expect(utility.stringifyValues({
      "a": 1,
      "b": "b",
      "c": true
    })).toEqual({
      "a": "1",
      "b": "b",
      "c": true
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

  describe('#exists', () => {
    it('returns true if an object exists, false otherwise', () => {
      expect(utility.exists(0)).toBe(true);
      expect(utility.exists(undefined)).toBe(false);
      expect(utility.exists(null)).toBe(false);
    });
  });
  
  describe('#isEmpty', () => {
    it("discovers if an object is empty", () => {
      expect(utility.isEmpty({"foo": "bar"})).toEqual(false);
      expect(utility.isEmpty({})).toEqual(true);
    });

    it('discovers if an array is empty', () => {
      expect(utility.isEmpty([])).toEqual(true);
      expect(utility.isEmpty([1, 2])).toEqual(false);
    });
  });
});


describe('redirectTo', ()=>{
  it('calls replace with path', () => {
    jest.spyOn(document.location, 'replace').mockImplementation(x => x);
    utility.redirectTo('/example/path');
    expect(document.location.replace.mock.calls.length).toEqual(1);
  });
});


describe('#createElementWithText', () => {
  document.body.innerHTML = '<div id="test"><div/>';
  
  it('creates a new element', () => {
    document
      .getElementById('test')
      .appendChild(utility.createElementWithText('p', 'just a simple paragraph'));

    expect( document.querySelector('#test > p').innerHTML).toEqual('just a simple paragraph');
  });
});

describe('#createElement', () => {
  beforeEach(() => document.body.innerHTML = '<div id="create-element-test"></div>');
  
  it('defaults to div', () => {
    document.getElementById('create-element-test').appendChild(utility.createElement());
    expect(document.querySelectorAll('#create-element-test > div').length ).toEqual(1);
  });

  it('can be initalized with a class', () => {
    document.getElementById('create-element-test')
      .appendChild(utility.createElement({ "tag": 'span', "class": 'one two'}));
    expect(document.querySelector('#create-element-test > span.one.two')).toBeTruthy();
  });

  it('can be initalized with an id', () => {
    document.getElementById('create-element-test')
      .appendChild(utility.createElement({ "id": 'foolsGold'}));
    expect(document.getElementById('foolsGold')).toBeTruthy();
  });

  it('create an element with text', () => {
    document.getElementById('create-element-test')
      .appendChild(utility.createElement({ "id": 'example', "tag": 'span', "text": 'example' }));

    expect(document.getElementById('example').textContent).toEqual('example');
  });
});


describe('#createLink', () => {
  beforeEach(() => document.body.innerHTML = '<div id="test-dom"></div>');  

  it('creates a new link', () => {
    document.getElementById('test-dom')
      .appendChild( utility.createLink('https://example.com/'));

    var link = document.querySelector('#test-dom > a');
    expect( link['href']).toEqual('https://example.com/');
    expect( link.text).toEqual('');
  });

  it('can creates a new link with text', () => {
    document.getElementById('test-dom')
      .appendChild( utility.createLink('https://example.com/', 'a website'));

    var link = document.querySelector('#test-dom > a');
    expect( link['href']).toEqual('https://example.com/');
    expect( link.text).toEqual('a website');
  });
});
