import React from 'react';
import PropTypes from 'prop-types';

import { formatIapdOwnerName } from '../helpers';

export default class NewEntityForm extends React.Component {
  static propTypes = {
    "cancel": PropTypes.func.isRequired,
    "doMatch": PropTypes.func.isRequired,
    "entityName": PropTypes.string
  };

  static defaultProps = { "entityName": '' };

  constructor(props) {
    super(props);
    this.state = {
      name: formatIapdOwnerName(this.props.entityName),
      blurb: '', primary_ext: null
    };
  }
  
  handleNameChange = e => this.setState({name: e.target.value })
  handleBlurbChange = e => this.setState({blurb: e.target.value })
  handlePrimaryExtChange = e => this.setState({primary_ext: e.target.value })

  handleSubmitForm = e => {
    e.preventDefault();
    if (e.target.checkValidity()) {
      this.props.doMatch(this.state);
    }
  }

  render() {
    return <form className="entity-matcher-new-entity-form" onSubmit={this.handleSubmitForm}>
             <div className="form-group new-entity-form-input">
               <label>Name</label>
               <input onChange={this.handleNameChange}
                      id="entity-name-input"
                      type="text"
                      name="entityName"
                      value={this.state.name}
                      className="form-control"
                      required />
             </div>

             <div className="form-group new-entity-form-input">
               <label>Blurb</label>
               <input onChange={this.handleBlurbChange}
                      id="entity-blurb-input"
                      type="text"
                      name="entityBlurb"
                      className="form-control"
                      placeholder="a short sentence or phrase" />
             </div>
             
             <div id="entity-primary-ext-radio" className="form-group new-entity-form-input radio" onChange={this.handlePrimaryExtChange}>
               <div className="form-check form-check-inline">
                 <input id="new-entity-form-primary-ext-person" className="form-check-input" type="radio" name="entityType" value="Person" required />
                 <label className="form-check-label" htmlFor="new-entity-form-primary-ext-person">Person</label> 
               </div>
               <div className="form-check form-check-inline">
                 <input id="new-entity-form-primary-ext-org" className="form-check-input" type="radio" name="entityType" value="Org" required />
                 <label className="form-check-label" htmlFor="new-entity-form-primary-ext-org">Org</label> 
               </div>
             </div>

             <div className="new-entity-form-button">
               <button type="submit" id="new-entity-form-button-submit" className="btn btn-primary">Create entity and match</button>
               <button type="button" id="new-entity-form-button-cancel" className="btn btn-light ml-2" onClick={this.props.cancel}>Cancel</button>
             </div>
           </form>;
  }
}
