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

// ACTIONS
import {
  loadItemInfo,
  loadMatches,
  ignoreMatch,
  doMatch,
  nextItem
} from './actions';

// STATUS HELPERS
const LOADING = 'LOADING';
const COMPLETE = 'COMPLETE';
const ERROR = 'ERROR';

const defaultState = () => ({
  "itemId": null, // item id (row id of External Dataset)
  "itemInfo": null, // json of external dataset attributes
  "itemInfoStatus": null, // status item info http request
  "matches": null, // Array of potential matches 
  "matchesStatus": null, // statues of potential matches http request
  "matchedState": null // Has it been matched: MATCHING, MATCHED, ERROR
});

export default class EntityMatcherUI extends React.Component {
  static propTypes = {
    "itemId": PropTypes.oneOfType([ PropTypes.string, PropTypes.number]).isRequired,    "dataset": PropTypes.string,
    "flow": PropTypes.string.isRequired
  };

   static defaultProps = {
    dataset: 'iapd'
  }

  constructor(props) {
    super(props);
    this.state = merge(defaultState(), { "itemId": props.itemId });
    
    this.updateState = this.updateState.bind(this);
    this.resetState = this.resetState.bind(this);
    this.loadItemInfoAndMatches = this.loadItemInfoAndMatches.bind(this);

    // Actions
    // These functions essentially constitute the public API
    this.loadItemInfo = loadItemInfo.bind(this);
    this.loadMatches = loadMatches.bind(this);
    this.ignoreMatch = ignoreMatch.bind(this);
    this.doMatch = doMatch.bind(this);
    this.nextItem = nextItem.bind(this);
  }

  resetState() {
    this.setState(defaultState());
  }

  /**
   * Updates state by recursive merging (via lodash's merge) the new object with current state.
   *
   * Additionally, It allows a second synatx for updating the state:
   *   updateState(key, value)
   * which is the same as updateState({ key: value })* 
   *
   * @param {Object|String} newStateOrKey
   * @param {Any} value
   */
  updateState(newStateOrKey, value) {
    if (isPlainObject(newStateOrKey)) {
      this.setState( (state, props) => merge({}, state, newStateOrKey) );
    } else {
      this.setState( (state, props) => merge({}, state, { [newStateOrKey]: value }) );
    }
  }

  
  loadItemInfoAndMatches() {
    if (!this.state.itemInfo) {
      this.loadItemInfo(this.state.itemId);
    }

    if (isNull(this.state.matchesStatus)) {
      this.loadMatches(this.state.itemId);
    }
  }

  componentDidMount() {
    this.loadItemInfoAndMatches();
  }

  render() {
    const itemInfoLoading = this.state.itemInfoStatus === LOADING;
    const itemInfoComplete = this.state.itemInfoStatus === COMPLETE;
    const itemInfoError = this.state.itemInfoStatus === ERROR;

    return(
      <div id="entity-matcher-ui">
        <div className="leftSide">
          { itemInfoLoading && <LoadingSpinner /> }
          { itemInfoError && <ApiError /> }
          {
            itemInfoComplete &&
            <>
              <DatasetItemHeader itemId={this.state.itemId}  />
              <DatasetItemInfo itemInfo={this.state.itemInfo} />
              <DatasetItemFooter nextItem={this.nextItem} />
            </>
          }
        </div>
        <div className="rightSide">
          <PotentialMatches ignoreMatch={this.ignoreMatch}
                            doMatch={this.doMatch}
                            matches={this.state.matches}
                            matchesStatus={this.state.matchesStatus} />
        </div>
      </div>
    );
  }
}
