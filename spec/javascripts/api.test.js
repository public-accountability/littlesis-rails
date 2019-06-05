import { qs } from 'packs/common/api';

describe('qs', () =>{
  test('appends ? to strings', () => {
    expect(qs('foo=bar')).toEqual('?foo=bar');
  });


  test('converts object', () => {
    expect(qs({foo: 'bar', number: 1})).toEqual('?foo=bar&number=1');
  });
  
  test('returns blank string otherwise', () => {
    expect(qs(null)).toEqual('');
  });


});
