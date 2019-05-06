import React from 'react';
import PropTypes from 'prop-types';

export default class NewEntityForm extends React.Component {
  static propTypes = {
    "cancel": PropTypes.func.isRequired,
    "doMatch": PropTypes.func.isRequired
  }

  constructor(props) {
    super(props);
    this.state = { name: '', blurb: '', primary_ext: null };
  }
  
  handleNameChange = e => this.setState({name: e.target.value })
  handleBlurbChange = e => this.setState({blurb: e.target.value })
  handlePrimaryExtChange = e => this.setState({primary_ext: e.target.value })

  handleSubmitForm = e => this.props.doMatch(this.state);

  render() {
    return <div className="entity-matcher-new-entity-form">
             <div className="new-entity-form-input">
               <label>Name</label>
               <input onChange={this.handleNameChange}
                      id="entity-name-input"
                      type="text"
                      name="entityName"
                      required="TRUE" />
             </div>

             <div className="new-entity-form-input">
               <label>Blurb</label>
               <input onChange={this.handleBlurbChange}
                      id="entity-blurb-input"
                      type="text"
                      name="entityBlurb"
                      placeholder="(optional) a short sentence or phrase" />
             </div>
             
             <div id="entity-primary-ext-radio" className="new-entity-form-input radio" onChange={this.handlePrimaryExtChange}>
               <label>Person</label> 
               <input type="radio" name="entityType" value="Person" />
               <label>Org</label> 
               <input type="radio" name="entityType" value="Org" />
             </div>

             <div className="new-entity-form-button">
               <button id="new-entity-form-button-submit" onClick={this.handleSubmitForm}>Create new entity and match</button>
               <button id="new-entity-form-button-cancel" onClick={this.props.cancel}>Cancel</button>
             </div>
           </div>;
  }
}
