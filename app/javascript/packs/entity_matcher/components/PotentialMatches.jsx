import React from 'react';
import isNull from 'lodash/isNull';

import LoadingSpinner from './LoadingSpinner';
import PotentialMatchesHeader from './PotentialMatchesHeader';
import PotentialMatchesSearch from './PotentialMatchesSearch';
import PotentialMatchesList from './PotentialMatchesList';

export default class PotentialMatches extends React.Component {

  constructor(props) {
    super(props);
  }

  render() {
    const isLoading = isNull(this.props.matchesStatus) || this.props.matchesStatus === 'LOADING';
    const hasMatches = this.props.matchesStatus === 'COMPLETE' && this.props.matches.results.length > 0;
    const noMatches = this.props.matchesStatus === 'COMPLETE' && this.props.matches.results.length == 0;

    return <div id="potential-matches">
             <PotentialMatchesHeader />
             { isLoading &&  <LoadingSpinner /> }
             { (hasMatches || noMatches) && <PotentialMatchesSearch /> }
             { hasMatches && <PotentialMatchesList matches={this.props.matches} /> }
           </div>;
  }
};
