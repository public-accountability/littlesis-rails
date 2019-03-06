import React from 'react';

import curry from 'lodash/curry';
import isNull from 'lodash/isNull';

import LoadingSpinner from './LoadingSpinner';
import PotentialMatchesHeader from './PotentialMatchesHeader';
import PotentialMatchesSearch from './PotentialMatchesSearch';
import PotentialMatchesList from './PotentialMatchesList';

export default class PotentialMatches extends React.Component {
  render() {
    const isLoading = isNull(this.props.matchesStatus) || this.props.matchesStatus === 'LOADING';
    const hasMatches = this.props.matchesStatus === 'COMPLETE' && this.props.matches.results.length > 0;
    const noMatches = this.props.matchesStatus === 'COMPLETE' && this.props.matches.results.length == 0;

    return <div id="potential-matches">
             <PotentialMatchesHeader />
             { isLoading &&  <LoadingSpinner /> }
             { (hasMatches || noMatches) && <PotentialMatchesSearch /> }
             { hasMatches && <PotentialMatchesList
                               ignoreMatch={this.props.ignoreMatch}
                               matches={this.props.matches} /> }
           </div>;
  }
};



