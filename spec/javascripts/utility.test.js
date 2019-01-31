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
