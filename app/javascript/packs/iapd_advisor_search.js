/*
  search for iapd advisors and display results in a table

  see views/external_dataset/search
*/
import assign from 'lodash/assign';
import template from 'lodash/template';
import { lsPost } from './common/http';
import { entityLink } from './common/utility';

const SEARCH_URL = '/external_datasets/iapd/search';

const IDS = {
  "button":            'iapd-search-button',
  "input":             'iapd-search-input',
  "tableContainer":    'iapd-table-container'
};

const advisorMatchUrl = id => `/external_datasets/iapd?flow=advisors&start=${id}`;

const matchLinkTemplate = template(`<a class="text-primary" role="button" href="<%= matchUrl %>">match</a>`);
const entityLinkTemplate = template(
  `<span class="font-weight-bold"">Already matched:</span>
   <a href="/entities/<%= entity_id %>" class="text-secondary" target="_blank">view entity profile page</a>
`);

const renderMatchOrEntityLink = (advisor) => advisor.entity_id
      ? entityLinkTemplate(advisor)
      : matchLinkTemplate(advisor);

const tableRowTemplate = template(`
<tr>
  <td><%- row_data.name %></td>
  <td><%= renderMatchOrEntityLink(obj) %></td>
</tr>`, { imports: { "renderMatchOrEntityLink": renderMatchOrEntityLink }}); 


const getSearchTerm = () => document.getElementById(IDS.input).value;

const handleSearchClick = (f) => document.getElementById(IDS.button).addEventListener('click', f);
const fetchAdvisors = (query) => lsPost(SEARCH_URL, { q: query });

const tableHtml = (advisors) => {
  let rows = advisors
      .map(a => assign(a, { "matchUrl": advisorMatchUrl(a.id) }))
      .map(tableRowTemplate)
      .join('');
  
  return `<table class="table">
            <tbody>${rows}</tbody>
          </table>`;
};

const displayTable = (advisors) => document.getElementById(IDS.tableContainer).innerHTML = tableHtml(advisors);

const displayNoResults = () => {
  let noResults = `<div class="alert alert-dark mt-4" role="alert" style="max-width: 200px;">
                     <span>No advisors found.</span>
                    </div>`;
  document.getElementById(IDS.tableContainer).innerHTML = noResults;
};

const displayError = (err) => {
  console.error(err);
  let errorAlert = `<div class="alert alert-warning mt-4" role="alert" style="max-width: 200px;">
                     <span>Something went wrong</span>
                    </div>`;
};

const displayAdvisors = advisors => advisors && advisors.length > 0
      ? displayTable(advisors)
      : displayNoResults();

const main = () => {
  handleSearchClick(() => {
    fetchAdvisors(getSearchTerm())
      .then(displayAdvisors)
      .catch(displayError);
  });
};

document.addEventListener("DOMContentLoaded", () => main());
