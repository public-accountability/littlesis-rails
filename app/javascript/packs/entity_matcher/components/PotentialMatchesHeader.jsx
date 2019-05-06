import React from 'react';

export default function PotentialMatchesHeader({showCreateNewEntityForm}) {
  const text = showCreateNewEntityForm
        ? 'Create a new entity:'
        : 'Possible LittleSis Matches';

  return <h2 className="text-center">{text}</h2>;
}
