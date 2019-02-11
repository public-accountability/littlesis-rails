import React from 'react';
import { Map } from 'immutable';
import { toInteger } from 'lodash-es';

// const stateUpdater = (updateState, oldState) => {
//   return (field, value) => updateState(oldState.set(field, value));
// };

const defaultState = () => Map({
  "entityId": null,
  "entityInfo": null,
  "matches": null,
  "selectedMatch": null,
  "ignoredMatches": null
});

// const EntityTitle = () => (
//   <div>
//     <h2>Entity matcher</h2>
//     <hr />
//   </div>
// );

// const EntityInfoDisplay = ({title, value}) => (
//   <>
//     <strong>{title}</strong> <span>{value}</span>
//   </>
// );

// const EntityInfo = ({displayData}) => (
//   <div id="entity-info">
//     { displayData.map( (x, i) => <EntityInfoDisplay key={i} title={x.title} value={x.value} />) }
//   </div>
// );

export class EntityMatcherUI extends React.Component {
  constructor (props) {
    super(props);
    this.state = defaultState();
  }

  render() {
    return(
      <>
        <h1>test</h1>
        {/* <EntityTitle /> */}
        {/* <EntityInfo displayData={this.displayData} /> */}
      </>
    );
  }
}
