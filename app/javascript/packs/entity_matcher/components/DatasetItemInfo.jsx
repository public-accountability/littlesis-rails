import React from 'react';
import PropTypes from 'prop-types';

/*
  html elements
    #dataset-item-info (div)
    .item-info-title (span)
    .item-info-value (span)
    .item-info-wrapper (div)
*/

export default function DatasetItemInfo(props) {

  let titleMaker = (title) => <span className="item-info-title">{title}</span>;
  let valueMaker = (value) => <span className="item-info-value">{value}</span>;

  let info = props.datasetFields.map( f => {
    return <div className="item-info-wrapper" key={`item-info-${f}`}>
             {titleMaker(f)}
             {valueMaker(props.itemInfo[f])}
           </div>;
  });
  
  return <div id="dataset-item-info"><div id="test">{info}</div></div>;
};


DatasetItemInfo.propTypes = {
  "itemInfo": PropTypes.object,
  "datasetFields": PropTypes.array
};
