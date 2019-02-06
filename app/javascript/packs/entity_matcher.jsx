import React from 'react';
import ReactDOM from 'react-dom';
import { EntityMatcherUI } from './entity_matcher/EntityMatcherUI';
import { EntityMatcher } from './entity_matcher/EntityMatcher';

document.addEventListener('DOMContentLoaded', () => {
  const div = document.getElementById('entity-matcher');

  ReactDOM.render(
    <EntityMatcherUI />,
    document.getElementById('entity-matcher')
  );
});
