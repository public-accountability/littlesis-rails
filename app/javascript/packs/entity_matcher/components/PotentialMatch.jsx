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


const Buttons = ({ignoreMatch}) => {
  return <div className="potential-match-buttons f-item">
           <a>Match</a>
           <a onClick={ignoreMatch}>❌</a>
         </div>;
};


/**
 * props:
 *   match (object)
 *   ignoreMatch (function)
 */
export default function PotentialMatch(props) {
  const entity = props.match.entity;
  
  return <div className="potential-match-card">
           <Image entity={entity} />
           <Entity entity={entity} />
           <Buttons ignoreMatch={ e => props.ignoreMatch(props.match.entity.id) } />
         </div>;
};

PotentialMatch.propTypes = {
  "match": PropTypes.object.isRequired,
  "ignoreMatch": PropTypes.func.isRequired,
};
