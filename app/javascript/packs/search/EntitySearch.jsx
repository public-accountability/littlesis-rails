import React from 'react';
import PropTypes from 'prop-types';

export default class EntitySearch extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    console.log(event.target.value);
  }

  render () {
    return <input type="text" onChange={this.handleChange} />;
  }
}
