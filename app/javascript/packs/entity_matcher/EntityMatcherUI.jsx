import React from 'react';
import DatasetItemHeader from './components/DatasetItemHeader';
import PotentialMatches from './components/PotentialMatches';

const defaults = {
  "item_id": 456
};

export class EntityMatcherUI extends React.Component {
  render() {
    return(
      <>
        <div className="leftSide">
          <DatasetItemHeader item_id={defaults.item_id}/>
        </div>

        <div className="rightSide">
          <PotentialMatches />
        </div>

        
      </>
    );
  }
}
