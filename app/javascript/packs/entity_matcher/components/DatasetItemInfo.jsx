import React from 'react';
import PropTypes from 'prop-types';

import find from 'lodash/find';
import sortBy from 'lodash/sortBy';

import { capitalizeWords, formatMoney } from '../../common/utility';
import { formatIapdOwnerName } from '../helpers';

// Display a single title-value data item
const DatasetItemPresenter = ({title, value}) => {
  return <div className="item-info-wrapper">
           <span className="item-info-title">{title}</span>
           <span className="item-info-value">{value}</span>
         </div>;
};

/*
  Extracts simple fields from dataset
  Iapd Owner and Adivsors have a different set of fields in `row data`

  input: Object
  output: Array[ Array[String, String|Number] ]
*/
const dataToKeyValues= (rowData) => {
  const latestRecord = sortBy(rowData.data, 'filename').slice(-1)[0];

  if (rowData['class'].includes('IapdOwner')) {
    return [
      ["Dataset", "IAPD Owner"],
      ["Name", formatIapdOwnerName(rowData.name)],
      ["Owner Key", rowData.owner_key],
      ["Schedule", latestRecord.schedule],
      ["Title/Status", capitalizeWords(latestRecord.title_or_status)],
      ["Advisor", capitalizeWords(find(rowData.associated_advisors, { "crd_number": toInteger(latestRecord.advisor_crd_number) }).name) ],
      ["Acquired", latestRecord.acquired]
    ];
  }
  
  if (rowData['class'].includes('IapdAdvisor')) {
    return [
      ["Dataset", "IAPD Advisor"],
      ["Name", capitalizeWords(rowData.name)],
      ["CRD Number", rowData.crd_number],
      ["Sec File Number", latestRecord.sec_file_number],
      ["Assets under management", formatMoney(latestRecord.assets_under_management, { truncate: true })]
    ];
  }

  throw "unknown external dataset class";
};


/*
  html elements
    #dataset-item-info (div)
    .item-info-wrapper (div)
    .item-info-title (span)
    .item-info-value (span)
*/
export default function DatasetItemInfo({itemInfo}) {
  const items = dataToKeyValues(itemInfo.row_data)
        .map( (pair, i) => <DatasetItemPresenter key={i} title={pair[0]} value={pair[1]} /> );

  return <div id="dataset-item-info">
           {items}
         </div>;
};

DatasetItemInfo.propTypes = { "itemInfo": PropTypes.object };
