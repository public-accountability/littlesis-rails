import React from 'react';
import ReactDOM from 'react-dom';
import get from 'lodash/get';
import EntityMatcher from './entity_matcher/EntityMatcher';


window.entityMatcher = function(options) {
  options = options || {};
  let dataset = get(options, 'dataset', 'iapd');
  let id = get(options, 'id', 'entity-matcher');
  let flow = get(options, 'flow', 'advisors');
  let start = get(options, 'start', null);
  let queue = get(options, 'queue', null)
  let queueMeta = get(options, 'queueMeta', {})

  ReactDOM.render(
    <EntityMatcher start={start} dataset={dataset} flow={flow} queue={queue} queueMeta={queueMeta} />,
    document.getElementById(id)
  );
};
