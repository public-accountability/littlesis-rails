import React from 'react';
import PropTypes from 'prop-types';

export default function DatasetItemHeader(props) {
  return <p className="dataset-item-header">Unmatched Item #{props.item_id}</p>;
};


DatasetItemHeader.propTypes = {
  "item_id": PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number
  ])
};
