import React from 'react';
import PropTypes from 'prop-types';

import at from 'lodash/at';
import curry from 'lodash/curry';
import isNull from 'lodash/isNull';

import LoadingSpinner from './LoadingSpinner';
import PotentialMatchesHeader from './PotentialMatchesHeader';
import PotentialMatchesSearch from './PotentialMatchesSearch';
import PotentialMatchesList from './PotentialMatchesList';
import CreateNewEntityButton from './CreateNewEntityButton';
import NewEntityForm from './NewEntityForm';

import { formatIapdOwnerName, isOwnerPerson } from '../helpers';

export default class PotentialMatches extends React.Component {
  static propTypes = {
    "matchesStatus": PropTypes.string,
    "matches": PropTypes.shape({
      "results": PropTypes.array,
      "automatchable": PropTypes.bool
    }),
    "ignoreMatch": PropTypes.func,
    "doMatch": PropTypes.func.isRequired,
    "itemId": PropTypes.oneOfType([ PropTypes.string, PropTypes.number]).isRequired,
    "itemInfo": PropTypes.object
  };
  
  constructor(props) {
    super(props);

    let name = at(props.itemInfo, 'row_data.name')[0];
    let formattedName = formatIapdOwnerName(name, isOwnerPerson(props.itemInfo.row_data));

    this.state =  {
      "showCreateNewEntityForm": false,
      "formattedName": formattedName
    };
  }
  
  render() {
    const isLoading = isNull(this.props.matchesStatus) || this.props.matchesStatus === 'LOADING';
    const hasMatches = this.props.matchesStatus === 'COMPLETE' && this.props.matches.results.length > 0;
    const noMatches = this.props.matchesStatus === 'COMPLETE' && this.props.matches.results.length == 0;
    const showCreateNewEntityForm = this.state.showCreateNewEntityForm;
    const showPotentialMatchesList = hasMatches && !showCreateNewEntityForm;

    return <div id="potential-matches">
             <PotentialMatchesHeader showCreateNewEntityForm={showCreateNewEntityForm} />
             { isLoading && <LoadingSpinner /> }
             { (hasMatches || noMatches) && <PotentialMatchesSearch /> }
             { showPotentialMatchesList && <PotentialMatchesList
                                             itemId={this.props.itemId}
                                             ignoreMatch={this.props.ignoreMatch}
                                             doMatch={this.props.doMatch}
                                             matches={this.props.matches} /> }

             { showCreateNewEntityForm && <NewEntityForm
                                            doMatch={curry(this.props.doMatch)(this.props.itemId)}
                                            cancel={ () => this.setState({ showCreateNewEntityForm: false }) }
                                            entityName={this.state.formattedName}
                                          />  }

             { !showCreateNewEntityForm &&  <CreateNewEntityButton
                                              handleClick={ () => this.setState({ showCreateNewEntityForm: true}) }
                                              noMatches={noMatches} /> }
           </div>;
  }
};



