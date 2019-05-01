import React from 'react';
import PropTypes from 'prop-types';

import curry from 'lodash/curry';
import isNull from 'lodash/isNull';

import LoadingSpinner from './LoadingSpinner';
import PotentialMatchesHeader from './PotentialMatchesHeader';
import PotentialMatchesSearch from './PotentialMatchesSearch';
import PotentialMatchesList from './PotentialMatchesList';
import CreateNewEntityButton from './CreateNewEntityButton';


export default class PotentialMatches extends React.Component {
  static propTypes = {
    "matchesStatus": PropTypes.string,
    "matches": PropTypes.shape({
      "results": PropTypes.array,
      "automatchable": PropTypes.bool
    }),
    "ignoreMatch": PropTypes.func,
    "doMatch": PropTypes.func,
    "itemId": PropTypes.oneOfType([ PropTypes.string, PropTypes.number]).isRequired
  };
  
  
  render() {
    const isLoading = isNull(this.props.matchesStatus) || this.props.matchesStatus === 'LOADING';
    const hasMatches = this.props.matchesStatus === 'COMPLETE' && this.props.matches.results.length > 0;
    const noMatches = this.props.matchesStatus === 'COMPLETE' && this.props.matches.results.length == 0;

    return <div id="potential-matches">
             <PotentialMatchesHeader />
             { isLoading &&  <LoadingSpinner /> }
             { (hasMatches || noMatches) && <PotentialMatchesSearch /> }
             { hasMatches && <PotentialMatchesList
                               itemId={this.props.itemId}
                               ignoreMatch={this.props.ignoreMatch}
                               doMatch={this.props.doMatch}
                               matches={this.props.matches} /> }
             <CreateNewEntityButton />
           </div>;
  }
};



