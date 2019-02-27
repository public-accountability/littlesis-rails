import React from 'react';
import DatasetItemHeader from './components/DatasetItemHeader';
import PotentialMatches from './components/PotentialMatches';
import DatasetItemInfo from './components/DatasetItemInfo';
import LoadingSpinner from './components/LoadingSpinner';

const defaults = {
  "item_id": 456
};

export class EntityMatcherUI extends React.Component {
  render() {
    return(
      <div id="entity-matcher-ui">
        <div className="leftSide">
          <DatasetItemHeader item_id={defaults.item_id}/>
          <LoadingSpinner />
          <DatasetItemInfo />
        </div>

        <div className="rightSide">
          <PotentialMatches />
        </div>
      </div>
    );
  }
}
