import React from 'react';
import PropTypes from 'prop-types';

export default function DatasetItemFooter(props) {
  return <div className="dataset-item-footer">
           <div className="d-flex">
             {/* <div> */}
             {/*   <a >« Previous</a> */}
             {/* </div> */}
             <div className="ml-auto">
               <a>Next »</a>
             </div>
           </div>
         </div>;
};
