import React from 'react';
import PropTypes from 'prop-types';

import PotentialMatch from './PotentialMatch';

export default function PotentialMatchesList(props) {
  let matchesList = props.matches.results
      .map( (match, i) => <PotentialMatch
                            key={`potential-match-${i}`}
                            ignoreMatch={props.ignoreMatch}
                            match={match} />);
  
  return <div id="potential-matches-list">
           { matchesList }
         </div>;
}

PotentialMatchesList.propTypes = {
  "matches": PropTypes.object.isRequired,
  "ignoreMatch": PropTypes.func,
};
