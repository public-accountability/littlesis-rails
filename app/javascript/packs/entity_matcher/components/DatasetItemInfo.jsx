import React from 'react';
import PropTypes from 'prop-types';

import castArray from 'lodash/castArray';
import find from 'lodash/find';
import toInteger from 'lodash/toInteger';
import orderBy from 'lodash/orderBy';

import { capitalizeWords, formatMoney } from '../../common/utility';
import { formatIapdOwnerName, isOwnerPerson } from '../helpers';

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

  input: object, [object]
  output: Array[ Array[String, String|Number] ]
*/
const dataToKeyValues= (rowData, queueMeta) => {
  if (rowData['class'].includes('IapdOwner')) {
    let latestRecord;
    let advisorName;

    if (queueMeta && queueMeta.crd_number) {
      latestRecord = find(rowData.data, x => x['advisor_crd_number'] == queueMeta.crd_number)
      advisorName = queueMeta.name
    } else {
      latestRecord = orderBy(rowData.data, ['filename', 'schedule'], ['desc', 'asc'])[0];
      advisorName = capitalizeWords(find(rowData.associated_advisors, { "crd_number": toInteger(latestRecord.advisor_crd_number) }).name)
    }

    return [
      ["Dataset", "IAPD Owner"],
      ["Name", formatIapdOwnerName(rowData.name, isOwnerPerson(rowData))],
      ["Owner Key", rowData.owner_key],
      ["Schedule", latestRecord.schedule],
      ["Title/Status", capitalizeWords(latestRecord.title_or_status)],
      ["Advisor", capitalizeWords(find(rowData.associated_advisors, { "crd_number": toInteger(latestRecord.advisor_crd_number) }).name) ],
      ["Acquired", latestRecord.acquired]
    ];
  }
  
  if (rowData['class'].includes('IapdAdvisor')) {
    let latestRecord = orderBy(rowData.data, ['filename'], ['desc'])[0];
    
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


const IapdLink = ({crdNumber}) => {
  let url = `https://www.adviserinfo.sec.gov/IAPD/content/ViewForm/crd_iapd_stream_pdf.aspx?ORG_PK=${crdNumber}`;
  let name = `Form ADV: ${crdNumber}`;
  return <a target="_blank" href={url} >{name}</a>;
};

const renderIapdReference = rowData => {
  let crdNumbers = rowData.crd_number ?
      castArray(rowData.crd_number)
      : rowData.associated_advisors.map(a => a.crd_number);

  return crdNumbers.map(crdNumber => {
    return <div className="dataset-reference-link" key={crdNumber}>
             <IapdLink crdNumber={crdNumber} key={`iapd-link-${crdNumber}`} />
           </div>;
  });

};

/*
  html elements
    #dataset-item-info-container
    #dataset-item-info (div)
    .item-info-wrapper (div)
    .item-info-title (span)
    .item-info-value (span)
*/
export default function DatasetItemInfo({itemInfo, queueMeta}) {
  const showIapdReference = itemInfo.row_data['class'].toLowerCase().includes('iapd');

  const items = dataToKeyValues(itemInfo.row_data, queueMeta)
        .map( (pair, i) => <DatasetItemPresenter key={i} title={pair[0]} value={pair[1]} /> );

  return <div id="dataset-item-info-container" >
           <div id="dataset-item-info">
             {items}
           </div>
           { showIapdReference && renderIapdReference(itemInfo.row_data) }
         </div>;
};

DatasetItemInfo.propTypes = { "itemInfo": PropTypes.object.isRequired,
			      "queueMeta": PropTypes.object };
