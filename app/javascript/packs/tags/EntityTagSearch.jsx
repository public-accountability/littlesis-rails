import React from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash/debounce';

const EntityResult = ({entity}) => {
  return <div className="entity-result">

           <img
             src={entity.image_url}
             alt={`LittleSis entity: ${entity.name}`}
           />

           <a href={entity.url}><p>{entity.name}</p></a>
           <p className="entity-result-blurb">{entity.blurb}</p>
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
    "delay":  PropTypes.number.isRequired
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
    return <input type="text"
                  className="entity-tag-search"
                  value={this.state.value}
                  onChange={this.handleChange} />;
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
    return `/search/entity?q=${q}&tags=${t}`;
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
      return <p>No entities found</p>;
    };

    return <EntityResults entities={this.state.entities} />;
  }

}



export default class EntityTagSearch extends React.Component {
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
             <SearchInput handleInputChange={this.handleInputChange} />
             { this.state.query && <FoundEntities tag={this.props.tag} query={this.state.query} key={this.state.query} /> }
           </>;
  }
}
