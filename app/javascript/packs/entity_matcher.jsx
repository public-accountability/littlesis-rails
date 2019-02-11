import React from 'react';
import ReactDOM from 'react-dom';
import { EntityMatcherUI } from './entity_matcher/EntityMatcher';

document.addEventListener('DOMContentLoaded', () => {
  const div = document.getElementById('entity-matcher');

  ReactDOM.render(
    <EntityMatcherUI entityId="1" />,
    document.getElementById('entity-matcher')
  );
});
