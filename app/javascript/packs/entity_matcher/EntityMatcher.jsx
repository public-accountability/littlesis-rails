import React from 'react';
import PropTypes from 'prop-types';
import { Store } from '@public-accountability/simplestore';
import EntityMatcherUI from './EntityMatcherUI'
import { defaultState } from './actions';

/*
 *
 */
export default class EntityMatcher extends React.Component {
  static propTypes = {
    "dataset": PropTypes.string.isRequired,
    "flow": PropTypes.string.isRequired,
    "start": PropTypes.any
  }

  static defaultProps = { dataset: 'iapd' }

  constructor(props) {
    super(props)
    let initialStoreMap = props.start ? defaultState.merge({ itemId: props.start }) : defaultState;
    let globalProps = { "dataset": props.dataset,
			"flow": props.dataset,
			"nextItemUrl":  `/external_datasets/${props.dataset}/flow/${props.flow}/next` };
    
    this.store = new Store(this, initialStoreMap, globalProps);
  }

  render() {
    return <div className="entity-matcher-root">
	     <EntityMatcherUI store={this.store} />
	   </div>;
  }
  
}
