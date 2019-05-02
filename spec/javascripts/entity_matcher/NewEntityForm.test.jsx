import React from 'react';
import { shallow, render } from 'enzyme';

import NewEntityForm from 'packs/entity_matcher/components/NewEntityForm';

describe('NewEntityForm', () => {
  let doMatch, form;

  beforeEach(() => {
    doMatch= jest.fn();
    form = shallow(<NewEntityForm
                     cancel={jest.fn()}
                     doMatch={doMatch}/>);
  });
  
  
  test('has name and blurb inputs', () => {
    expect(form.find('#entity-name-input').length).toEqual(1);
    expect(form.find('#entity-blurb-input').length).toEqual(1);
  });

  test('has person/org selector', () => {
    expect(form.find('[type="radio"]').length).toEqual(2);
  });

  test('has submit and cancel buttons', () => {
    expect(form.find('button').length).toEqual(2);
  });

  test('clicking submit calls doMatch', () => {
    form.find('#entity-name-input').simulate('change', { target: { value: 'foo' } });
    form.find('#entity-blurb-input').simulate('change', { target: { value: 'bar' } });
    form.find('#entity-primary-ext-radio').simulate('change', { target: { value: 'Org' } });
    form.find('#new-entity-form-button-submit').simulate('click');

    expect(doMatch.mock.calls.length).toEqual(1);
    expect(doMatch.mock.calls[0][0]).toEqual({ name: 'foo', blurb: 'bar', primary_ext: 'Org'});
  });

  test.todo('validates name field');

});
