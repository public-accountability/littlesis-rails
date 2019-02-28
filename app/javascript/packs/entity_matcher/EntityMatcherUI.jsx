import React from 'react';

//  LODASH
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
  "datasetFields": []
});


// ACTIONS
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



export default class EntityMatcherUI extends React.Component {

  constructor(props) {
    super(props);
    this.state = merge({}, defaultState(), { "datasetFields": props.datasetFields});
    this.loadItemInfo = loadItemInfo.bind(this);
  }

  /**
   * I don't like how setState doesn't recursively merge objects. That's very annoying!
   * So my "updateState" uses lodash's merge to recursive combine the objects before sending
   * them to setState. Yes, I could use redux or something, but I'll stick with this function 
   * until I feel like that's needed.
   *
   * Additionally, It allows a second synatx for updating the state:
   *   updateState(key, value)
   * which is the same as updateState({ key: value })
   */
  updateState(newStateOrKey, value) {
    if (isPlainObject(newStateOrKey)) {
      this.setState( (state, props) => merge({}, state, newStateOrKey) );
    } else {
      this.setState( (state, props) => merge({}, state, { [newStateOrKey]: value }) );
    }
  }

  componentDidMount() {
    if (!this.state.itemInfo) {
      this.loadItemInfo();
    }
  }


  // componentDidUpdate() {
  //   console.log(this.state);
  // }

  render() {

    const itemInfoLoading = this.state.itemInfoStatus === LOADING;
    const itemInfoComplete = this.state.itemInfoStatus === COMPLETE;
    const itemInfoError = this.state.itemInfoStatus === ERROR;

    return(
      <div id="entity-matcher-ui">
        <div className="leftSide">
          { itemInfoLoading && <LoadingSpinner /> }
          { itemInfoError && <p>ERROR</p> }
          {
            itemInfoComplete &&
            <>
              <DatasetItemHeader itemId={this.state.itemId}  />
              <DatasetItemInfo itemInfo={this.state.itemInfo} />
            </>
          }
        </div>
        <div className="rightSide">
          <PotentialMatches />
        </div>
      </div>
    );
  }
}
