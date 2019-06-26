import React from 'react';
import PropTypes from 'prop-types';

//  LODASH
import merge from 'lodash/merge';
import isPlainObject from 'lodash/isPlainObject';
import isNull from 'lodash/isNull';

// COMPONENTS
import ApiError from './components/ApiError';
import DatasetItemHeader from './components/DatasetItemHeader';
import DatasetItemInfo from './components/DatasetItemInfo';
import DatasetItemFooter from './components/DatasetItemFooter';
import LoadingSpinner from './components/LoadingSpinner';
import PotentialMatches from './components/PotentialMatches';
import ConfirmationPage from './components/ConfirmationPage';

// ACTIONS
import actions from './actions';

// STATUS HELPERS
const LOADING = 'LOADING';
const COMPLETE = 'COMPLETE';
const ERROR = 'ERROR';
const MATCHING = 'MATCHING';
const MATCHED = 'MATCHED';

export default class EntityMatcherUI extends React.Component {
  static propTypes = { "store": PropTypes.object.isRequired };

  constructor(props) {
    super(props);
    this.actions = actions.withStore(props.store);
  }

  componentDidMount() {
    if (this.props.store.get('itemId')) {
      this.actions.loadItemInfoAndMatches();
    } else {
      this.actions.nextItem();
    }
  }

  render() {
    const store = this.props.store;	
    const itemInfoLoading = store.get('itemInfoStatus') === LOADING;
    const itemInfoComplete = store.get('itemInfoStatus') === COMPLETE;
    const itemInfoError = store.get('itemInfoStatus') === ERROR;
    const matchingInProgress = store.get('matchedState') === MATCHING;
    const isMatched = store.get('matchedState') === MATCHED;
    const matchingError = store.get('matchedState') === ERROR;
    const showPotentialMatches = itemInfoComplete && !(matchingInProgress || isMatched || matchingError);
    const { matches, matchesStatus, itemId, itemInfo } = store.toJS();

    const renderPotentialMatches = () => {
      return <PotentialMatches
	       ignoreMatch={this.actions.ignoreMatch}
	       doMatch={this.actions.doMatch}
	       actions={this.actions}
               matches={matches}
               matchesStatus={matchesStatus}
               itemId={itemId}
               itemInfo={itemInfo} />;
    };

    return(
      <div id="entity-matcher-ui">
        <div className="leftSide">
          { itemInfoLoading && <LoadingSpinner /> }
          { itemInfoError && <ApiError /> }
          {
            itemInfoComplete &&
            <>
              <DatasetItemHeader itemId={itemId}  />
              <DatasetItemInfo itemInfo={itemInfo} />
              <DatasetItemFooter nextItem={this.actions.nextItem} />
            </>
          }
        </div>

	<div className="rightSide">
          { matchingInProgress && <LoadingSpinner /> }
          { isMatched && <ConfirmationPage
                           matchResult={this.store.get('matchResult')}
                           nextItem={this.actions.nextItem}
                         /> }
          { matchingError && <ApiError /> }
          { showPotentialMatches && renderPotentialMatches() }
        </div>
      </div>
    );
  }
}
