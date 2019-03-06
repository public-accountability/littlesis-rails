import React from 'react';

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


const Buttons = (props) => {
  return <div className="potential-match-buttons f-item">
           <a>Match</a>
           <a>❌</a>
         </div>;
};


export default function PotentialMatch(props) {
  const entity = props.match.entity;
  
  return <div className="potential-match-card">
           <Image entity={entity} />
           <Entity entity={entity} />
           <Buttons />
         </div>;
};
