import React from 'react';
import ReactDOM from 'react-dom';
import get from 'lodash/get';
import EntityMatcherUI from './entity_matcher/EntityMatcherUI';


window.entityMatcher = function(options) {
  options = options || {};
  let dataset = get(options, 'dataset', 'iapd');
  let id = get(options, 'id', 'entity-matcher');
  let flow = get(options, 'flow', 'advisors');
  let start = get(options, 'start', null);

  ReactDOM.render(
    <EntityMatcherUI itemId={start} dataset={dataset} flow={flow} />,
    document.getElementById(id)
  );
};
