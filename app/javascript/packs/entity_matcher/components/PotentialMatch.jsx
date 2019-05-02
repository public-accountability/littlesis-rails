import React from 'react';
import PropTypes from 'prop-types';

const Image = ({entity}) => {
  return <div className="potential-match-entity-image-wrapper f-item">
           <img
             src={entity.image_url}
             alt={`Image of LittleSis entity: ${entity.name}`}
           />
         </div>;

};

const Entity = ({entity}) => {
  return <div className="potential-match-entity f-item">
           <a href={entity.url} ><h1>{entity.name}</h1></a>
           <p className="potential-match-entity-blurb">{entity.blurb}</p>
         </div>;
  
};


/**
 * Match and ignore match buttons
 * Currently, the ignore match button is show shown (but the functionality exists) 
 *
 * @param {Function} ignoreMatch
 * @param {Function} doMatch
 * @returns {} 
 */
const Buttons = ({ignoreMatch, doMatch}) => {
  return <div className="potential-match-buttons f-item">
           <a className="mr-1" onClick={doMatch}>Match</a>
           {/* <a onClick={ignoreMatch}>❌</a> */}
         </div>;
};


/**
 * props:
 *   match (object)
 *   ignoreMatch (function)
 */
export default class PotentialMatch extends React.Component {
  static propTypes = {
    "match": PropTypes.object.isRequired,
    "ignoreMatch": PropTypes.func.isRequired,
    "doMatch": PropTypes.func.isRequired,
    "itemId": PropTypes.oneOfType([ PropTypes.string, PropTypes.number]).isRequired
  }

  render () {
    const entity = this.props.match.entity;
    
    return <div className="potential-match-card">
             <Entity entity={entity} />
             <Buttons
               ignoreMatch={ e => this.props.ignoreMatch(entity.id) }
               doMatch={ e => this.props.doMatch(this.props.itemId, entity.id) }
             />
           </div>;
  }
  
};
