import React from 'react';
import PropTypes from 'prop-types';

import PotentialMatch from './PotentialMatch';

export default function PotentialMatchesList(props) {
  let matchesList = props.matches.results
      .map( (match, i) => <PotentialMatch
                            itemId={props.itemId}
                            key={`potential-match-${i}`}
                            ignoreMatch={props.ignoreMatch}
                            doMatch={props.doMatch}
                            match={match} />);
  
  return <div id="potential-matches-list">
           { matchesList }
         </div>;
}

PotentialMatchesList.propTypes = {
  "matches": PropTypes.object.isRequired,
  "ignoreMatch": PropTypes.func,
  "doMatch": PropTypes.func.isRequired,
  "itemId": PropTypes.oneOfType([ PropTypes.string, PropTypes.number]).isRequired
};
