import React from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash/debounce';

const EntityResult = ({entity}) => {
  return <div className="entity-result mt-1 mb-1">
           <div className="media">
             <img
               src={entity.image_url}
               className="entity-result-img mr-3"
               alt={`LittleSis entity: ${entity.name}`}
             />
             <div className="media-body">
               <a href={entity.url} target="_blank">
                 <h5 className="mt-0">{entity.name}</h5>
               </a>
               <span className="entity-result-blurb">{entity.blurb}</span>
             </div>
           </div>
         </div>;
};

const EntityResults = ({entities}) => {
  return <div className="entity-results">
           { entities
             .map( (entity, i) => <EntityResult entity={entity} key={`entity-result-${i}`} />) }
         </div>;
};

class SearchInput extends React.Component {
  static propTypes = {
    "handleInputChange": PropTypes.func.isRequired,
    "delay":  PropTypes.number.isRequired,
    "tag": PropTypes.string.isRequired
  };

  static defaultProps = { "delay": 250 };

  constructor(props) {
    super(props);
    this.state = { "update": null, "value": '' };
    this.updateQuery = debounce(this.props.handleInputChange, this.props.delay);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange (event) {
    let value = event.target.value;

    this.setState((state, props) => {
      if (state.update) state.update.cancel();
      return { "value": value, "update": this.updateQuery(value) };
    });
  }

  render () {
    return <div className="entity-tag-search-heading d-flex mb-2">
             <h3>Find entities tagged with {this.props.tag}</h3>
             <input type="text"
                    className="entity-tag-search-input ml-3"
                    value={this.state.value}
                    onChange={this.handleChange} />

           </div>;
  }
}



class FoundEntities extends React.Component {
  static propTypes = {
    "tag": PropTypes.string.isRequired,
    "query": PropTypes.string.isRequired
  };

  constructor(props) {
    super(props);
    this.abortController = new window.AbortController();
    this.state = { entities: null };
  }

  searchUrl(query, tag) {
    let q = encodeURIComponent(query);
    let t = encodeURIComponent(tag);
    let num = 5;
    return `/search/entity?q=${q}&include_image_url=TRUE&tags=${t}&num=${num}`;
  }

  componentDidMount () {
    let url = this.searchUrl(this.props.query, this.props.tag);

    fetch(url, { "signal": this.abortController.signal })
      .then( r => r.json())
      .then( json => this.setState({ "entities": json }))
      .catch( err => {
        if (err.name == 'AbortError') { return; }
        throw err;
      });
  }

  componentWillUnmount () {
    this.abortController.abort();
  }

  render () {
    if (!this.state.entities) {
      return <></>;
    };

    if (this.state.entities.length === 0) {
      return <p className="no-entities-found">No entities found</p>;
    };

    return <EntityResults entities={this.state.entities} />;
  }

}



export default class  EntityTagSearch extends React.Component {
  static propTypes = {
    "tag": PropTypes.string.isRequired
  }

  constructor(props) {
    super(props);
    this.state = { "query": null };
    this.handleInputChange = this.handleInputChange.bind(this);
  }

  handleInputChange(value) {
    this.setState({query: value});
  }

  render () {
    return <>
             <SearchInput handleInputChange={this.handleInputChange} tag={this.props.tag} />
             { this.state.query && <FoundEntities tag={this.props.tag} query={this.state.query} key={this.state.query} /> }
           </>;
  }
}
