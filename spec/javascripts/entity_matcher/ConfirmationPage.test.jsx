import React from 'react';
import { shallow, render, mount } from 'enzyme';

import ConfirmationPage, { computeResultStats } from 'packs/entity_matcher/components/ConfirmationPage';


describe('computeResultStats', () => {

  const testResults = ['relationship_created', 'advisor_not_matched', 'owner_not_matched', 'relationship_exists', 'relationship_created'];
  const testStats = { advisor_not_matched: 1,
                      owner_is_org: 0,
                      owner_not_matched: 1,
                      relationship_exists: 1,
                      relationship_created: 2 };

  test('calculates stats', () => {
    expect(computeResultStats(testResults)).toEqual(testStats);
  });

  describe('rendering message', () => {
    const matchResult = {
      status: 'ok',
      results: testResults,
      entity: {
        "id": 1000,
        "name": 'test',
        "blurb": null,
        "summary": null,
        "notes": null,
        "website": null,
        "parent_id": null,
        "primary_ext": "Org",
        "created_at": "2019-04-13 14:33:56 UTC",
        "updated_at": "2019-04-13 14:33:56 UTC",
        "start_date": null,
        "end_date": null,
        "is_current": null,
        "is_deleted": false,
        "merged_id": null,
        "link_count":  2,
        "url": "http://localhost:8080/org/1000-test"
      }
    };

    const confirmationPage = render(<ConfirmationPage matchResult={matchResult} nextItem={jest.fn()} itemId={1} flow="advisors" />);
    const pageText = confirmationPage.text();

    test('contains entity link', () => {
      let component = shallow(<ConfirmationPage matchResult={matchResult} nextItem={jest.fn()} itemId={1} flow="advisors"/>);
      expect(component.find('a').first().props().href).toEqual("http://localhost:8080/org/1000-test");
      expect(pageText).toMatch(/entity has been successfully matched/);
    });

    test('displays confirmation messages', () =>{
      expect(pageText).toMatch(/1 executive has been added to the matching queue/);
      expect(pageText).toMatch(/1 relationship already exists in the LittleSis database/);
      expect(pageText).toMatch(/1 advisor has not yet been matched/);
      expect(pageText).toMatch(/2 relationships have been created/);
    });

    test('next item link', () => {
      const nextItemMock = jest.fn();
      let component = shallow(<ConfirmationPage matchResult={matchResult} nextItem={nextItemMock} itemId={1} flow="advisors"/>);
      expect(component.find('a.nextItem').exists()).toBe(true);
      component.find('a.nextItem').simulate('click');
      expect(nextItemMock.mock.calls.length).toBe(1);
    });

    test('contains OwnerQueueLink when matching advisor', ()=>{
      let advisorFlowPage = mount(<ConfirmationPage matchResult={matchResult} nextItem={jest.fn()} itemId={1} flow="advisors"/>);
      let ownerFlowPage = mount(<ConfirmationPage matchResult={matchResult} nextItem={jest.fn()} itemId={2} flow="owners"/>);
      expect(advisorFlowPage.find('a.ownerQueueLink').exists()).toBe(true);
      expect(ownerFlowPage.find('a.ownerQueueLink').exists()).toBe(false);
    });
  });
});

