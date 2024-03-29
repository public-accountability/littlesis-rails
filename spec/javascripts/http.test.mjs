import { qs }  from '../../app/javascript/src/common/http.mjs';
import assert from 'assert';

describe('qs', () =>{
  it('appends ? to strings', () => {
    assert.equal(qs('foo=bar'), '?foo=bar');
  });

  it('converts object', () => {
    assert.equal(qs({foo: 'bar', number: 1}), '?foo=bar&number=1');
  });

  it('returns blank string otherwise', () => {
    assert.equal(qs(null), '');
  });
});
