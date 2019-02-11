import React from 'react';
import { Map } from 'immutable';
import { toInteger } from 'lodash-es';

const defaultState = () => Map({
  "entityId": null,
  "entityInfo": null,
  "matches": null,
  "selectedMatch": null,
  "ignoredMatches": null
});

export const EntityTitle = () => (
  <div>
    <h2>Entity matcher</h2>
    <hr />
  </div>
);

const EntityInfoDisplay = ({title, value}) => (
  <>
    <strong>{title}</strong> <span>{value}</span>
  </>
);

const EntityInfo = ({entityInfo}) => (
  <div id="entity-info">
    { entityInfo.map( (x, i) => <EntityInfoDisplay key={i} title={x.title} value={x.value} />) }
  </div>
);


const fetchEntityInfo = (entityId) => {
  const data = [ {"title": 'one', "value": 1}, {"title": 'two', "value": 2} ];
  return new Promise((resolve, reject) => setTimeout(() => resolve(data), 2000));
};
  

/**
 * Stores all state data in key "data", where "data" is an immutable.js Map
 * this.set(k, v) and this.get(k) updates the state
 */
export class EntityMatcherUI extends React.Component {
  constructor (props) {
    super(props);
    this.state = { "data": defaultState().set('entityId', toInteger(props.entityId)) };
  }

  setImmState(fn) {
    return this.setState( ({data}) => ({ data: fn(data) }) );
  }

  set(field, value) {
    this.setImmState((data) => data.set(field, value));
  }

  get(field) {
    return this.state.data.get(field);
  }

  componentDidMount() {
    fetchEntityInfo(this.get('entityId'))
      .then( x => this.set('entityInfo', x));
  }

  render() {
    return(
      <>
      <EntityTitle />
        { this.get('entityInfo') && <EntityInfo entityInfo={this.get('entityInfo')} /> }
      </>
    );
  }
}
