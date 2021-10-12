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
  return <div className="entity-search-suggestion">
           <div className="entity-search-suggestion-name">
             <span className="entity-search-suggestion-name-text font-weight-bold">
               {entity.name}
             </span>
             <span className="entity-search-suggestion-name-link">
               <a href={entity.url} target="_blank">
                 <i class="bi bi-box-arrow-up-right"></i>
               </a>
             </span>
           </div>
           <div className="entity-search-suggestion-blurb">
             {entity.blurb}
           </div>
         </div>;
};

export class AutocompleteBox extends React.Component {
  static propTypes = { "tag": PropTypes.string }

  constructor(props) {
    super(props);
    this.state = { "entities": [] };
    this.abortController = new window.AbortController();
  }

  componentDidMount () {
    let url = searchUrl(this.props.query, this.props.tag);

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
      return <div className="entity-search-menu empty"></div>;
    }

    return <div className="entity-search-menu">
             <div className="entity-search-dataset"/>
             { this.state.entities
               .map((entity, i) => <AutocompleteEntity entity={entity} key={`autocomplete-entity-${i}-${entity.name}`} />)
             }
             <div/>
           </div>;
  }
};


export class EntitySearch extends React.Component {
  static propTypes = {
    "tag": PropTypes.string
  }

  constructor(props) {
    super(props);
    this.state = { "query": '' };
    this.onInputChange = this.onInputChange.bind(this);
    this.onClickSearch = this.onClickSearch.bind(this);
    this.renderInput = this.renderInput.bind(this);
    this.hasQuery = this.hasQuery.bind(this);
    this.handleKeyPress = this.handleKeyPress.bind(this);
  }

  onInputChange(event) {
    let value = event.target.value.trim();
    this.setState({ "query": value });
  }

  onClickSearch() {
    let tag = this.props.tag;
    let query = this.state.query;

    if (tag) {
      window.location= `/search?q=${query}&tags=${tag}`;
    } else {
      window.location= `/search?q=${query}`;
    }
  }

  handleKeyPress(event) {
    // Enter does same thing as clicking the search button
    if (event.key === 'Enter') {
      this.onClickSearch();
    }
  }

  hasQuery() {
    return this.state.query.trim().length >= 3;
  }

  renderInput() {
    return <div className="entity-search-input-group">
             <input type="text"
                    className="form-control"
                    onChange={this.onInputChange}
                    value={this.state.query}
                    onKeyPress={this.handleKeyPress} />
             <div className="input-group-append">
               <button type="submit" className="btn btn-clear" onClick={this.onClickSearch} >
	         <i className="bi bi-search"></i>
               </button>
             </div>
           </div>;
  }

  render () {
    return <div className="entity-search-container">
             { this.renderInput() }
             { this.hasQuery() &&
               <AutocompleteBox
                 query={this.state.query}
                 tag={this.props.tag}
                 key={`autocomplete-${this.state.query}`} /> }
           </div>;
  }
}
