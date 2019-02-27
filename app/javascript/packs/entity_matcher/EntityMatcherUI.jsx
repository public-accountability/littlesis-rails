import React from 'react';
import merge from 'lodash/merge';
import isPlainObject from 'lodash/isPlainObject';

// COMPONENTS
import DatasetItemHeader from './components/DatasetItemHeader';
import DatasetItemInfo from './components/DatasetItemInfo';
import LoadingSpinner from './components/LoadingSpinner';
import PotentialMatches from './components/PotentialMatches';

// API
import { retriveDatasetRow } from './api_client';

// STATUS HELPERS
const LOADING = 'LOADING';
const COMPLETE = 'COMPLETE';
const ERROR = 'ERROR';

const defaultState = () => ({
  "itemId": 2,
  "itemInfo": null,
  "itemInfoStatus": null,
});


// Actions

// These need to be bound with `this` before being called
export function loadItemInfo() {
  this.updateState("itemInfoStatus", LOADING);

  retriveDatasetRow(this.state.itemId)
    .then(json => this.updateState({ "itemInfoStatus": COMPLETE, "itemInfo": json }))
    .catch(error => {
      console.error('[loadItemInfo]: ', error.message);
      this.updateState("itemInfoStatus", ERROR);
    });
};

export class EntityMatcherUI extends React.Component {

  constructor(props) {
    super(props);
    this.state = defaultState();
  }

  updateState(newStateOrKey, value) {
    if (isPlainObject(newStateOrKey)) {
      this.setState(merge({}, this.state, newStateOrKey));
    } else {
      this.setState(merge({}, this.state, Object.fromEntries([[newStateOrKey, value]])));
    }
  }

  componentDidMount() {
    if (!this.state.itemInfo) {
      loadItemInfo.call(this);
    }
  }

  render() {
    return(
      <div id="entity-matcher-ui">
        <div className="leftSide">
          { (this.state.itemInfoStatus === LOADING) && <LoadingSpinner /> }
          { (this.state.itemInfoStatus === ERROR) && <p>ERROR</p> }
          { (this.state.itemInfoStatus === COMPLETE) && <DatasetItemHeader itemId={this.state.itemId} /> }
          { (this.state.itemInfoStatus === COMPLETE) && <DatasetItemInfo itemInfo={this.state.itemInfo} /> }
        </div>
        <div className="rightSide">
          <PotentialMatches />
        </div>
      </div>
    );
  }
}
