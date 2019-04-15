import React from 'react';
import PropTypes from 'prop-types';

// SEARCH HTTP REQUESTS

const searchUrl = (query, tag = null) => {
  let num = 5;
  let url = `/search/entity?q=${encodeURIComponent(query)}&num=${num}`;

  if (tag) {
    return `${url}&tags=${encodeURIComponent(tag)}`;
  } else {
    return url;
  }
};

const surpressAbortError = err => {
  if (err.name == 'AbortError') { return; }
  throw err;
};

// COMPONENTS //

export const AutocompleteEntity = ({entity}) => {
  return <li>
           <p>
             <a href={entity.url} target="_blank">{entity.name}</a>
           </p>
         </li>;
};

export class AutocompleteBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = { "entities": [] };
    this.abortController = new window.AbortController();
  }
  
  componentDidMount () {
    let url = searchUrl(this.props.query);

    window.fetch(url, { "signal": this.abortController.signal })
      .then(r => r.json())
      .then(json => this.setState({ "entities": json }))
      .catch(surpressAbortError);
  }

  componentWillUnmount () {
    this.abortController.abort();
  }

  render () {
    if (this.state.entities.length === 0) {
      return <div className="entity-search-autocomplete-empty"></div>;
    }

    return <div className="entity-search-autocomplete">
             <ul>
               { this.state.entities
                 .map((entity, i) => <AutocompleteEntity entity={entity} key={`autocomplete-entity-${i}-${entity.name}`} />)
               }
             </ul>
           </div>;
  }
};


export class EntitySearch extends React.Component {
  constructor(props) {
    super(props);
    this.state = { "query": '' };
    this.onInputChange = this.onInputChange.bind(this);
    this.hasQuery = this.hasQuery.bind(this);
  }

  onInputChange(event) {
    let value = event.target.value.trim();
    this.setState({ "query": value });
  }

  hasQuery() {
    return this.state.query.trim().length >= 3;
  }

  render () {
    return <div className="entity-search-container">
             <input type="text"
                    onChange={this.onInputChange}
                    value={this.state.query} />
             { this.hasQuery() && <AutocompleteBox query={this.state.query} key={`autocomplete-${this.state.query}`} /> }
           </div>;
  }
}

