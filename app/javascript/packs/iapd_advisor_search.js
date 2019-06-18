/*
  Searches for iapd advisor and display results in a table

  see views/external_dataset/search
*/
import { lsPost } from './common/http';

const SEARCH_URL = '/external_datasets/iapd/search';
const IDS = { "button": 'iapd-search-button', "input":  'iapd-search-input' };

const getSearchTerm = () => document.getElementById(IDS.input).value;
const handleSearchClick = (f) => document.getElementById(IDS.button).addEventListener('click', f);
const fetchAdvisors = (query) => lsPost(SEARCH_URL, { q: query });

const main = () => {
  handleSearchClick(() => {
    fetchAdvisors(getSearchTerm())
      .then(x => console.log(x));
  });
};

document.addEventListener("DOMContentLoaded", () => main());

