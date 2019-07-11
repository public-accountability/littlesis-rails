import React from 'react';
import PropTypes from 'prop-types';
import { List } from 'immutable';
import isNil from 'lodash/isNil';
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
    "start": PropTypes.any,
    "queue": PropTypes.array,
    "queueMeta": PropTypes.object
  }

  static defaultProps = {
    dataset: 'iapd',
    queueMeta: {}
  }

  constructor(props) {
    super(props);
    let initState = defaultState;

    if (props.start) {
      initState = initState.set('itemId', props.start)
    }

    if (props.flow === 'queue') {
      if (isNil(props.queue)) {
	throw new Error('The flow queue also requires the param queue');
      }

      initState = initState.merge({
	"itemId": props.queue[0],
	"queue": List(props.queue.slice(1))
      });
    }

    let globalProps = { "dataset": props.dataset,
			"flow": props.flow,
			"queueMeta": props.queueMeta,
			"nextItemUrl":  `/external_datasets/${props.dataset}/flow/${props.flow}/next` };

    this.store = new Store(this, initState, globalProps);
  }

  render() {
    return <div className="entity-matcher-root">
	     <EntityMatcherUI store={this.store} />
	   </div>;
  }
  
}
