import filter from 'lodash';
import capitalize from 'lodash';

import { capitalizeWords } from '../common/utility';

const formatIapdPersonOwner = str => {
  let names = str.split(',').map(s => s.trim()).map(capitalize);
  return `${names[0]} ${names.slice(1, names.length).join(' ')}`;
};

  
export const formatIapdOwnerName = str => {
  return (filter(str, s => s === ',').length >= 2)
    ? formatIapdPersonOwner(str)
    : capitalizeWords(str);
};
