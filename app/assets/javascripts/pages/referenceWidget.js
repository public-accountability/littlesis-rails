/**
 * Widget to select an existing reference or create a new one
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    root.ReferenceWidget = factory(root.jQuery, root.utility);
  }
}(this, function ($, utility) {
  // CONSTANTS
  var REFERENCES_PER_PAGE = 25;
  var REQUEST_URL = 'http://localhost:8080/references/recent';
    
  /**
   * Reference Widget
   * Use:  new ReferenceWidget([entity_ids], { options })
   * @param {Array|Integer|String} entityIds
   * @param {Object} userOptions
   */
  function ReferenceWidget(entityIds, userOptions) {
    this.options = mergeOptions(ReferenceWidget.DEFAULT_OPTIONS, userOptions);
    this.entityIds = [].concat(entityIds).map(function(n) { return Number(n); });
    this.documents = null;
    this.render = this._render.bind(this);
    this.init();
  }

  // STATIC VALUES
  ReferenceWidget.TYPEAHEAD_INPUT_ID = 'ref-widget-typeahead';
  ReferenceWidget.TYPEAHEAD_INPUT_SELECTOR = '#' + ReferenceWidget.TYPEAHEAD_INPUT_ID;
  ReferenceWidget.DEFAULT_OPTIONS = {
    "containerDiv": "#reference-widget-container",
    "afterRender": function() {}
  };

  /**
   * Initalize the ReferenceWidget 
   */
  ReferenceWidget.prototype.init = function() {
    this.getDocs().then(this.render);
  };
  
  /**
   * Replaces contents of container with typeahead
   */
  ReferenceWidget.prototype._render = function() {
    $(this.options.containerDiv).html(this._typeaheadInput());
    $(ReferenceWidget.TYPEAHEAD_INPUT_SELECTOR)
      .typeahead(null, this._typeaheadConfig());
    this.options.afterRender();
  };

  ///////////////////////////
  // TYPEAHEAD COMPONENTS ///
  //////////////////////////

  /**
   * Prepares Bloodhound search with provided references data
   * @param {Array[Referencs]} data
   * @returns {Bloodhound} 
   */
  function documentBloodhound(data) {
    return new Bloodhound({
      local: data,
      identify: function(doc) { return doc.id; },
      queryTokenizer: function(q) {
	return Bloodhound.tokenizers.whitespace(q.toLowerCase());
      },
      datumTokenizer: function(d) {
	return flatten(
	  [d.name, d.url]
	    .map(function(x) {
	      return Bloodhound.tokenizers.whitespace(x.toLowerCase());
	    })
	);
      }
    });
  }
  
  /**
   * Provides a configuartion object for typeahead
   * Requires `this.documents` to be set
   * @param {Array} references
   * @returns {Object} Configuration for typeahead 
   */
  ReferenceWidget.prototype._typeaheadConfig = function() {
    if (!Array.isArray(this.documents)) {
      throw 'Documents are missing or invalid :(';
    }
    
    return {
      name: 'references',
      source: documentBloodhound(this.documents),
      templates: {
	empty: '<p>empty</p>',
	suggestion: function(data) {
	  return '<p><strong>' + data.name + '</strong></p>';
	}
      }
    };
  };
  

  /**
   * Retrives recent documents via an ajax call to /references/recent
   * Sets this.documents if successful.
   * @returns {Promise}
   */
  ReferenceWidget.prototype.getDocs = function() {
    var self = this;
    var url = this._recentReferencesUrl();
    
    return new Promise(function(resolve, reject){
      $.getJSON(url)
	.done(function(data) {
	  self.documents = data;
	  resolve(data);
	})
	.fail(function(){
	  reject('failed to get references from /references/recent');
	});
    });
  };


  /**
   * Url for request
   * @returns {String} 
   */
  ReferenceWidget.prototype._recentReferencesUrl = function() {
    var params =  $.param({
      "entity_ids":  this.entityIds,
      "per_page": REFERENCES_PER_PAGE,
      "exclude_type": 'fec'
    });

    return REQUEST_URL + '?' + params;
  };



  ///////////////////
  // DOM ELEMENTS ///
  //////////////////
    
  /**
   * Input with id ref-widget-typeahead
   * @returns {<input>} 
   */
  ReferenceWidget.prototype._typeaheadInput = function() {
    return $('<input>', {
      "type": 'text',
      "placeholder": 'Select an existing reference',
      "id": ReferenceWidget.TYPEAHEAD_INPUT_ID
    });
  };
  


  ///////////////
  // HELPERS ///
  /////////////

  function mergeOptions(defaultOptions, provided) {
    return Boolean(provided) ? Object.assign({}, defaultOptions, provided) : defaultOptions;
  };

  function flatten(arrays) {
    return Array.prototype.concat.apply([], arrays);
  }

  return ReferenceWidget;  // Return the constructor
}));



