import React from 'react';
import PropTypes from 'prop-types';
import toPairs from 'lodash/toPairs';

/**
 * After matching, the rails API returns a list of results
 * See app/services/iapd_relationship_service.rb for more details
 *
 * @param {Array} results
 * @returns {Object} 
 */
export const computeResultStats = results => {
  return results.reduce(
    (acc, result) => {
      acc[result] += 1;
      return acc;
    },
    {
      advisor_not_matched: 0,
      owner_not_matched: 0,
      relationship_exists: 0,
      relationship_created: 0
    }
  );
};


const statText = {
  advisor_not_matched: {
    noun: ['advisor', 'advisors'],
    verb: ['has', 'have'],
    message: 'not yet been matched'
  },
  owner_not_matched: {
    noun: ['executive', 'executives'],
    verb: ['has', 'have'],
    message: 'been added to the matching queue'
  },
  relationship_exists: {
    noun: ['relationship', 'relationships'],
    verb: ['already exists', 'already exist'],
    message: 'in the LittleSis database'
  },
  relationship_created: {
    noun: ['relationship', 'relationships'],
    verb: ['has', 'have'],
    message: 'been created'
  }
};

/**
 * Message displaying sentence for the given statistic
 * @param {String} stat name of stat
 * @param {Integer} count value
 * @returns {ReactClass} 
 */
const StatMessage = ({stat, count}) => {
  if (count === 0) {
    return <></>;
  }

  let { noun, verb, message } = statText[stat];
  let grammarIndex = count > 1 ? 1 : 0;
  let text = [String(count), noun[grammarIndex], verb[grammarIndex], message].join(' ');

  return <p className="confirmation-page-stat">{text}</p>;
};


/**
 * Confirmation page showing result of matching operation.
 * Contains link to entity and a few sentences describing what happended.
 */
export default class ConfirmationPage extends React.Component {
  static propTypes = {
    matchResult: PropTypes.shape({
      status: PropTypes.string,
      results: PropTypes.array,
      entity: PropTypes.object
    }).isRequired
  }
  
  render() {
    let entity = this.props.matchResult.entity;
    let results = this.props.matchResult.results;

    let statMessages = toPairs(computeResultStats(results))
        .map(([stat, count]) => <StatMessage stat={stat} count={count} key={stat} />);

    return <div className="entity-matcher-confirmation-page">
             <h4>
               The entity has been successfully matched with <a href={entity.url}>{entity.name}</a>
             </h4>
             {statMessages}
           </div>;
  }
}
