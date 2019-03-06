import React from 'react';
import PotentialMatch from './PotentialMatch';

export default function PotentialMatcheslist(props) {
  let matchesList = props.matches.results
      .map( (match, i) => <PotentialMatch key={`potential-match-${i}`} match={match} />);
  
  return <div id="potential-matches-list">
           { matchesList }
         </div>;
}
