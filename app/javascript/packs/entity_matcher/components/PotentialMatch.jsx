import React from 'react';

const Image = (imageUrl, name) => {
  return <img src={imageUrl} alt={`Image of ${name}`} />;
};

export default function PotentialMatch() {
  return <div className="potential-match-card">
         </div>;
};
