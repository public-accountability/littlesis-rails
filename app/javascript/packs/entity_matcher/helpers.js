import filter from 'lodash';
import capitalize from 'lodash';

import { capitalizeWords } from '../common/utility';


const formatIapdPersonOwner = str => {
  let names = str.split(',').map(s => s.trim()).map(capitalize);
  return names.slice(1, names.length).concat(names[0]).join(' ');
};

  
export const formatIapdOwnerName = (str, isPerson) => {
  if (Boolean(isPerson) || filter(str, s => s === ',').length >= 2) {
    return formatIapdPersonOwner(str);
  } else {
    return capitalizeWords(str);
  }
};

export const isOwnerPerson = rowData => {
  if (rowData['class'].includes('IapdAdvisor')) {
    return false;
  }
  return rowData.data[0].owner_type === 'I';
};
