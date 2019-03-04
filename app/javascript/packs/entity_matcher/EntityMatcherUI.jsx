import React from 'react';
import PropTypes from 'prop-types';

//  LODASH
import merge from 'lodash/merge';
import isPlainObject from 'lodash/isPlainObject';

// COMPONENTS
import ApiError from './components/ApiError';
import DatasetItemHeader from './components/DatasetItemHeader';
import DatasetItemInfo from './components/DatasetItemInfo';
import LoadingSpinner from './components/LoadingSpinner';
import PotentialMatches from './components/PotentialMatches';

// ACTIONS
import { loadItemInfo } from './actions';

// STATUS HELPERS
const LOADING = 'LOADING';
const COMPLETE = 'COMPLETE';
const ERROR = 'ERROR';

const defaultState = () => ({
  "itemId": null,
  "itemInfo": null,
  "itemInfoStatus": null,
  "datasetFields": []
});

export default class EntityMatcherUI extends React.Component {

  constructor(props) {
    super(props);
    this.state = merge({}, defaultState(), props);
    this.updateState = this.updateState.bind(this);
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
      loadItemInfo(this.updateState, this.state.itemId);
    }
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
              <DatasetItemInfo itemInfo={this.state.itemInfo} datasetFields={this.state.datasetFields} />
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

EntityMatcherUI.propTypes = {
  "itemId": PropTypes.oneOfType([ PropTypes.string, PropTypes.number]).isRequired,
  "datasetFields": PropTypes.array.isRequired
};
