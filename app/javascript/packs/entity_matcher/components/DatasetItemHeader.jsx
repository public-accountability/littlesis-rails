import React from 'react';
import PropTypes from 'prop-types';

export default function DatasetItemHeader(props) {
  return <p className="dataset-item-header">Unmatched Item #{props.itemId}</p>;
};


DatasetItemHeader.propTypes = {
  "itemId": PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number
  ])
};
