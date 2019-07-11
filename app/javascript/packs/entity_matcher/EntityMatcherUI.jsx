import React from 'react';
import PropTypes from 'prop-types';

// COMPONENTS
import ApiError from './components/ApiError';
import DatasetItemHeader from './components/DatasetItemHeader';
import DatasetItemInfo from './components/DatasetItemInfo';
import DatasetItemFooter from './components/DatasetItemFooter';
import LoadingSpinner from './components/LoadingSpinner';
import PotentialMatches from './components/PotentialMatches';
import ConfirmationPage from './components/ConfirmationPage';
import EmptyQueueMessage from './components/EmptyQueueMessage';

// ACTIONS
import actions, { STATUS } from './actions';

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
    
    const itemInfoLoading = store.get('itemInfoStatus') === STATUS.LOADING;
    const itemInfoComplete = store.get('itemInfoStatus') === STATUS.COMPLETE;
    const itemInfoError = store.get('itemInfoStatus') === STATUS.ERROR;
    const isQueueFlow = store.globalProps.get('flow') === 'queue';
    const queueEmpty = isQueueFlow && store.get('queue').isEmpty();
    const matchingInProgress = store.get('matchedState') === STATUS.MATCHING;
    const isMatched = store.get('matchedState') === STATUS.MATCHED;
    const matchingError = store.get('matchedState') === STATUS.ERROR;
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
	  { queueEmpty && <EmptyQueueMessage />}
          {
            itemInfoComplete &&
            <>
              <DatasetItemHeader itemId={itemId}  />
              <DatasetItemInfo itemInfo={itemInfo}
			       queueMeta={store.globalProps.get('queueMeta')} />
              <DatasetItemFooter nextItem={this.actions.nextItem} />
            </>
          }
        </div>

	<div className="rightSide">
          { matchingInProgress && <LoadingSpinner /> }
          { isMatched && <ConfirmationPage
			   itemId={itemId}
			   flow={store.globalProps.get('flow')}
                           matchResult={store.get('matchResult')}
                           nextItem={this.actions.nextItem}
                         /> }
          { matchingError && <ApiError /> }
          { showPotentialMatches && renderPotentialMatches() }
        </div>
      </div>
    );
  }
}
