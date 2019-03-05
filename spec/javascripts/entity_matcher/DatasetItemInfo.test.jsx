import React from 'react';
import { render } from 'enzyme';

import DatasetItemInfo from 'packs/entity_matcher/components/DatasetItemInfo';

describe('DatasetItemInfo', () => {
  let info = { "one": 'foo', "two": 'bar', "three": 'baz' };
  let fields = [ "one", "two" ];
    
  const html = render(<DatasetItemInfo itemInfo={info} datasetFields={fields} />);
  
  it('has 2 title spans', () => expect(html.find('.item-info-title').length).toEqual(2));
  it('has 2 value spans', () => expect(html.find('.item-info-value').length).toEqual(2));
  it('has foo and bar, but not baz', () => {
    expect(html.text()).toMatch(/bar/);
    expect(html.text()).toMatch(/foo/);
    expect(html.text()).not.toMatch(/baz/);
  });
});
