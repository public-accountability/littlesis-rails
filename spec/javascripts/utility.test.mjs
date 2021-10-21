import utility from '../../app/javascript/src/common/utility.mjs';
import assert from 'assert'

describe('entityLink', () => {
  it('returns link for person', () => {
    assert.equal(utility.entityLink('123', 'jane doe', 'person'), 'https://littlesis.org/person/123-jane_doe');
  });

  it('returns link for org', () => {
    assert.equal(utility.entityLink('456', 'corp INC.', 'org'), 'https://littlesis.org/org/456-corp_INC.');
  });
});

describe('range', () => {
  it('returns range', () => {
    assert.deepEqual(utility.range(3), [0,1,2])
  });

  it('can optionally exclude numbers', () => {
    assert.deepEqual(utility.range(4, [1,2]), [0,3]);
  });
});

describe('randomDigitStringId', () => {
  it('returns 10 digits by default', () => {
    assert.equal(utility.randomDigitStringId().length, 10);
  });

  it('can return number of digits provided by value', () => {
    assert.equal(utility.randomDigitStringId(3).length, 3);
  });

  it('raises error if given more than 14 digits', () => {
    assert.throws(() => utility.randomDigitStringId(15))
  });
});

describe('entityInfo', () => {
  xit('returns the value of the data attribute', () => {
    document.body.innerHTML = '<div id="entity-info" data-foo="bar"><div/>';
    expect(utility.entityInfo('foo')).to.equal('bar');
  })
});

describe('relationship constants', () => {
  describe('#relationshipCategories', () => {
    it('returns an array', () => {
      assert.equal(Array.isArray(utility.relationshipCategories), true)
    });
  })

  describe('#extensionDefinitions', () => {
    it('returns an object', () => {
      assert.equal(typeof utility.extensionDefinitions, 'object')
    });
  })
});

describe('RelationshipDetails', () => {
  it('returns a nested array', () => {
    utility.range(13, [7]).slice(1).forEach( i => {
      const details = utility.relationshipDetails(i);

      assert.equal(Array.isArray(details), true);

      details.forEach(detail => {
        assert.equal(Array.isArray(detail), true);
        assert.equal(detail.length, 3)
        detail.forEach(x  => assert.equal(typeof x, 'string'));
      });
    });
  });

  xit('throws errors if not between 1-12 and not 7', () => {
    utility.range(13, [0, 7]).forEach( i => {
      expect(() => utility.relationshipDetails(i)).to.not.throw(Error);
    });
    expect(() => utility.relationshipDetails(7)).throw('Lobbying relationships are not currently supposed by the bulk add tool');
    const invalidMsg = "Invalid relationship category. It must be a number between 1 and 12";
    expect(() => utility.relationshipDetails(0)).throw(invalidMsg);
    expect(() => utility.relationshipDetails(13)).throw(invalidMsg);
  });
});

describe('#validDate', function() {
  it('is valid with good dates', function() {
    ['1992-12-00', '2016-01-01', '1992-12-03'].map(utility.validDate).forEach( d => assert.equal(d, true) );
  });

  it('is invalid with bad dates', function() {
    ['tuesday', '20000-01-01', '1888-01', '1999-13-02', '2000-01-50']
      .map(utility.validDate).forEach( d => assert.equal(d, false) );
  });
});

describe('#validURL', function(){
  it('is valid with a simple url', () => assert.equal(utility.validURL('https://simple.url'), true));
  it('is invalid with a bad url', () => assert.equal(utility.validURL('/not/a/url'), false));
});

describe('#validPersonName', () => {

  it('requires a first and last name', () => {
    assert.equal(utility.validPersonName('Oedipa'), false);
    assert.equal(utility.validPersonName('Oedipa Maas'), true);
  });

  it('rejects numerical characters', () => {
    assert.equal(utility.validPersonName('03d1p4 M445'), false);
  });

  it('allows lower case names', () => {
    assert.equal(utility.validPersonName('oedipa maas'), true);
  });

  it('allows hyphenated names', () => {
    assert.equal(utility.validPersonName('Oedipa-Wendell Mucho-Maas'), true);
  });

  it('allows prefixes and suffixes', () => {
    assert.equal(utility.validPersonName('Mrs. Oedipa Maas, Sr.'), true);
    assert.equal(utility.validPersonName('Mr. Wendell Maas, III'), true);
  });

  it('allows non-english unicode code points', () => {
    assert.equal(utility.validPersonName('OedìpⒶ Måăß 겫겫겫'), true);
  });

  it('allows very short names', () => {
    assert.equal(utility.validPersonName('W. A. S. T. E.'), true);
  });

  it('allows up to 5 names', () => {
    assert.equal(utility.validPersonName('trystero trystero trystero trystero trystero'), true);
  });
});

describe('string utilities', () => {
  describe('#capitalize', () => {
    it('capitalizes a single word', () => assert.equal(utility.capitalize("foobar"), "Foobar"));
  })

  describe('#capitalizeWords', () => {
    it('capitalizes multiple words', ()=> {
      assert.equal(utility.capitalizeWords('foo bar'), 'Foo Bar');
      assert.equal(utility.capitalizeWords('FOO BAR'), 'Foo Bar');
      assert.equal(utility.capitalizeWords('foo bar, llc'), 'Foo Bar, LLC');
      assert.equal(utility.capitalizeWords('company inc'), 'Company Inc');
    });

    it('capitalizes company names', ()=> {
      assert.equal(utility.capitalizeWords('company lp'), 'Company LP');
      assert.equal(utility.capitalizeWords('company l.p.'), 'Company L.P.');
      assert.equal(utility.capitalizeWords('company L.l.c.'), 'Company L.L.C.');
    });
  })

  describe('#formatIdSelector', () => {
    it('formats an ID selector', () => {
      assert.equal(utility.formatIdSelector('foo'), '#foo');
      assert.equal(utility.formatIdSelector('#foo'), '#foo');
    });
  })

  describe('#removeHashFromId', () => {
    it('remove hashes from IDs', () => {
      assert.equal(utility.removeHashFromId('foo'), 'foo');
      assert.equal(utility.removeHashFromId('#foo'), 'foo');
    });
  })

  describe('#formatMoney', () => {
    it('formats money strings correctly', () => {
      assert.equal(utility.formatMoney('1000'), '$1,000.00');
      assert.equal(utility.formatMoney('1000', { truncate: true }), '$1,000');
      assert.equal(utility.formatMoney(100500800.15), '$100,500,800.15');
      assert.equal(utility.formatMoney(100500800.15, { truncate: true }), '$100,500,800');
    });
  })
});

// describe('object utilities', () => {
//   describe('#isObject', () => {

//     it('returns true for an object', () => assert.equal(utility.isObject({}), true));

//     it('returns true for a function', () => assert.equal(utility.isObject(() => 'foo'), true));

//     it('returns false for a string', () => {
//       assert.equal(utility.isObject('foo'), false);
//       assert.equal(utility.isObject(''), false);
//     });

//     it('returns false for a boolean', () => {
//       assert.equal(utility.isObject(true), false);
//       assert.equal(utility.isObject(false), false);
//     });

//     it('returns false for null', () => assert.equal(utility.isObject(null)).to.be.false);
//     it('returns false for undefined', () => expect(utility.isObject(undefined)).to.be.false);
//   });

//   describe('#get', () => {
//     const obj = { a: 1, b: 2};

//     it('reads an arbitrary key from an object', () => {
//       expect(utility.get(obj, 'a')).to.equal(1);
//     });

//     it('handles non-existent properties', () => {
//       expect(utility.get(obj, "foo")).to.equal(undefined);
//     });

//     it('handles null objects', () => {
//       expect(utility.get(null, "foo")).to.equal(undefined);
//     });

//     it('handles undefined objects', () => {
//       expect(utility.get(undefined, "foo")).to.equal(undefined);
//     });
//   });

//   describe('#getIn', () => {
//     const nestedObj = { a: { b: 2, c: 3 } };
//     it('reads values from a nested sequence of keys in an object', () => {
//       expect(utility.getIn(nestedObj, ["a", "b"])).to.equal(2);
//     });

//     it('handles non-existent nested keys', () => {
//       expect(utility.getIn(nestedObj, ["a", "foo"])).to.equal(undefined);
//     });

//     it('handles lookup sequences that are longer than depth of object tree', () => {
//       expect(utility.getIn(nestedObj, ["a", "b", "d"])).to.equal(undefined);
//     });
//   });

//   describe('#set', () => {
//     const obj = { a: 1, b: 2};

//     it('sets the value for an arbitary key on an object', () => {
//       expect(utility.set(obj, 'c', 3)).to.eql({ a: 1, b: 2, c: 3 });
//     });

//     it('does not mutate objects', () => {
//       utility.set(obj, 'c', 3);
//       expect(obj).to.eql({ a: 1, b: 2});
//     });

//     it('does not allow newly created entries to be mutated', () => {
//       let _obj = utility.set(obj, 'c', 3);
//       expect(() => _obj.c = 4).throw(/Cannot assign to read only property/);
//     });

//     it('does allow newly created entries to be re-set', () => {
//       const _obj = utility.set(obj, 'c', 3);
//       const __obj = utility.set(_obj, 'c', 4);
//       expect(__obj.c).to.equal(4);
//     });
//   });

//   describe('#setIn', () => {
//     const nestedObj = { a: { b: 2, c: 3 } };

//     it('sets the value for a nested key in an object', () => {
//       expect(utility.setIn(nestedObj, ['a', 'b'], 4))
//         .to.eql({ a: { b: 4, c: 3 } });
//     });

//     it('creates and sets the value for a nested key in an object', () => {
//       expect(utility.setIn(nestedObj, ['a', 'd'], 4))
//         .to.eql({ a: { b: 2, c: 3, d: 4 } });
//     });

//     it("handles paths longer than tree", () => {
//       expect(utility.setIn(nestedObj, ["a", "d", "e"], 4))
//         .to.eql({ a: { b: 2, c: 3, d: { e: 4 } } });
//     });

//     it('handles wierd paths', () => {
//       expect(utility.setIn(nestedObj, ['a', 'b', 'c'], 4))
//         .to.eql({ a: { b: { c: 4}, c: 3 } } );
//     });
//   });

//   describe('#del', () => {
//     const obj = { a: 1, b: 2};
//     it('removes an entry from an object', () => {
//       expect(utility.del(obj, 'a')).to.eql({ b: 2 });
//     });
//   });

//   describe('#deleteIn', () => {
//     const nestedObj = { a: { b: 2, c: 3 } };
//     it('removes a nested entry from an object', () => {
//       expect(utility.deleteIn(nestedObj, ['a', 'b']))
//         .to.eql({ a: { c: 3 } });
//     });
//   });

//   describe('#normalize', () => {

//     it('transforms an array of resources into a lookup table of resources by id', () => {
//       expect(utility.normalize(
//         [
//           { id: 'a', foo: 'bar' },
//           { id: 'b', foo: 'bar' }
//         ]
//       )).to.eql(
//         {
//           a: { id: 'a', foo: 'bar' },
//           b: { id: 'b', foo: 'bar' }
//         }
//       );
//     });
//   });

//   describe('stringifyValues', () => {
//     expect(utility.stringifyValues({
//       "a": 1,
//       "b": "b",
//       "c": true
//     })).to.eql({
//       "a": "1",
//       "b": "b",
//       "c": true
//     });
//   });

//   describe("#pick", () => {
//     it('returns object with a permitted set of keys', () => {
//       var obj = { a: 1, b: 2, c: 3 };
//       expect(utility.pick(obj, ['a', 'c']))
//         .to.eql({ a: 1, c: 3 });
//     });
//   });

//   describe("#omit", () => {
//     it('returns object without rejected set of keys', () => {
//       var obj = { a: 1, b: 2, c: 3 };
//       expect(utility.omit(obj, ['a', 'c']))
//         .to.eql({ b: 2 });
//     });
//   });

//   describe('#exists', () => {
//     it('returns true if an object exists, false otherwise', () => {
//       expect(utility.exists(0)).to.be.true;
//       expect(utility.exists(undefined)).to.be.false;
//       expect(utility.exists(null)).to.be.false;
//     });
//   });

//   describe('#isEmpty', () => {
//     it("discovers if an object is empty", () => {
//       expect(utility.isEmpty({"foo": "bar"})).to.be.false;
//       expect(utility.isEmpty({})).to.be.true;
//     });

//     it('discovers if an array is empty', () => {
//       expect(utility.isEmpty([])).to.be.true;
//       expect(utility.isEmpty([1, 2])).to.be.false;
//     });
//   });
// });

// describe('#createElementWithText', () => {
//   it('creates a new element', () => {
//     document.body.innerHTML = '<div id="test"><div/>';

//     document
//       .getElementById('test')
//       .appendChild(utility.createElementWithText('p', 'just a simple paragraph'));

//     expect( document.querySelector('#test > p').innerHTML).to.equal('just a simple paragraph');
//   });
// });


// describe('#createElement', () => {
//   beforeEach(() => document.body.innerHTML = '<div id="create-element-test"></div>');

//   it('defaults to div', () => {
//     document.getElementById('create-element-test').appendChild(utility.createElement());
//     expect(document.querySelectorAll('#create-element-test > div').length ).to.equal(1);
//   });

//   it('can be initalized with a class', () => {
//     document.getElementById('create-element-test')
//       .appendChild(utility.createElement({ "tag": 'span', "class": 'one two'}));
//     expect(document.querySelector('#create-element-test > span.one.two')).to.be.ok;
//   });

//   it('can be initalized with an id', () => {
//     document.getElementById('create-element-test')
//       .appendChild(utility.createElement({ "id": 'foolsGold'}));
//     expect(document.getElementById('foolsGold')).to.be.ok;
//   });

//   it('create an element with text', () => {
//     document.getElementById('create-element-test')
//       .appendChild(utility.createElement({ "id": 'example', "tag": 'span', "text": 'example' }));

//     expect(document.getElementById('example').textContent).to.equal('example');
//   });
// });


// describe('#createLink', () => {
//   beforeEach(() => document.body.innerHTML = '<div id="test-dom"></div>');

//   it('creates a new link', () => {
//     document.getElementById('test-dom')
//       .appendChild( utility.createLink('https://example.com/'));

//     var link = document.querySelector('#test-dom > a');
//     expect( link['href']).to.equal('https://example.com/');
//     expect( link.text).to.equal('');
//   });

//   it('can creates a new link with text', () => {
//     document.getElementById('test-dom')
//       .appendChild( utility.createLink('https://example.com/', 'a website'));

//     var link = document.querySelector('#test-dom > a');
//     expect( link['href']).to.equal('https://example.com/');
//     expect( link.text).to.equal('a website');
//   });
// });
