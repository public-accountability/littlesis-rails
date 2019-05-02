import React from 'react';
import PropTypes from 'prop-types';

export default class PotentialMatches extends React.Component {
  static propTypes = {
    noMatches: PropTypes.bool
  }

  render () {
    return <div className="create-new-entity-button mt-4 d-flex flex-column align-items-center text-center">
             { this.props.noMatches && <p className="w-100">No matches found. <br />Would you like to create a new entity?</p> }
             <a onClick={() => console.log('create new entity')} >Create New Entity »</a>
           </div>;
  }

}
