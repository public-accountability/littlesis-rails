import React from 'react';
import ReactDOM from 'react-dom';
import EntityMatcherUI from './entity_matcher/EntityMatcherUI';


document.addEventListener('DOMContentLoaded', () => {
  const div = document.getElementById('entity-matcher');

  ReactDOM.render(
    <EntityMatcherUI itemId={132531} />,
    document.getElementById('entity-matcher')
  );
});
