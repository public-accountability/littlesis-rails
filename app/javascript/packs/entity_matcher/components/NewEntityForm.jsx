import React from 'react';
import PropTypes from 'prop-types';

export default class NewEntityForm extends React.Component {
  render() {
    return <div className="entity-matcher-new-entity-form">
             <div className="new-entity-form-input">
               <label>Name</label>
               <input id="entity-name-input" type="text" name="entityName" required="TRUE" />
             </div>

             <div className="new-entity-form-input">
               <label>Blurb</label>
               <input id="entity-blurb-input" type="text" name="entityBlurb" placeholder="(optional) a short sentence or phrase" />
             </div>
             
             <div className="new-entity-form-input radio">
               <label>Person</label> 
               <input type="radio" name="entityType" value="Person" />
               <label>Org</label> 
               <input type="radio" name="entityType" value="org" />
             </div>

             <div className="new-entity-form-button">
               <button className="">Create new entity and match</button>
               <button className="">Cancel</button>
             </div>
           </div>;
  }
}
