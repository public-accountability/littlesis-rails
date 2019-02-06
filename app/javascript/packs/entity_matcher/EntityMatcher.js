import merge from 'lodash-es/merge';

const urls = {
  "loadInfo": "/admin/entity_matcher/info"
};


export const httpClient = (entity_id) => {
  return {
    "info": () => fetch(urls.loadInfo + `?entity_id=${this.entity_id}`),

    "matches": (x) => {
      let options = merge({"page": 1, "ignore": []}, x);
      // fetch();
    }
  };
};


/**
 * Class that holds all state for Entity Matcher
 * 
 */
export default class EntityMatcher extends React.Component {

  constructor(entityId) {
    this.state = {
      "entityId": entityId,
      "entityInfo": null

      
    };
    
    this.entity_id = entity_id;
    this.entityInfo = null;
    this.potentialMatches = null;
    this.selectedMatch = null;
    this.ignoredMatches = new Set();

    this.order = {};

    this.load();
  }

  /**
   * 
   * @param {String} field
   * @returns {Function} 
   */
  setField (field) {
    return data => this[field] = data;
  }

  load () {
    let testData = [ { title: "one", value: "1"}, { title: "foo", value: "bar"} ];

    new Promise( (resolve, reject) => setTimeout( () => resolve(testData)))
      .then(this.setField('entityInfo'));
  }
}
