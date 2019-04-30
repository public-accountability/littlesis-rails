import React from 'react';
import PropTypes from 'prop-types';

export default class DatasetItemFooter extends React.Component {
  static propTypes = {
    nextItem: PropTypes.func.isRequired
  };

  render() {
    return <div className="dataset-item-footer">
             <div className="d-flex">
               {/* <div> */}
               {/*   <a >« Previous</a> */}
               {/* </div> */}
               <div className="ml-auto">
                 <a
                   style={{cursor: 'pointer'}}
                   onClick={this.props.nextItem}>Next »</a>
               </div>
             </div>
           </div>;
  }
};
