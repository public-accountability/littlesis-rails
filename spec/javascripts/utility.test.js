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
  test('formatIdSelector', () => {
    expect(utility.formatIdSelector('foo')).toEqual('#foo');
    expect(utility.formatIdSelector('#foo')).toEqual('#foo');
  });
});
