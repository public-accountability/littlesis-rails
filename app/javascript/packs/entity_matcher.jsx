import React from 'react';
import ReactDOM from 'react-dom';
import { EntityMatcherUI } from './entity_matcher/EntityMatcherUI';


document.addEventListener('DOMContentLoaded', () => {
  const div = document.getElementById('entity-matcher');

  const datasetFields = ["Full Legal Name", "Title or Status", "OwnerID"];

  ReactDOM.render(
    <EntityMatcherUI datasetFields={datasetFields} />,
    document.getElementById('entity-matcher')
  );
});
