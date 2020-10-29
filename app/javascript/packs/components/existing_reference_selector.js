/**
 * Widget to select an existing reference
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('../common/utility'));
  } else {
    root.ExistingReferenceWidget = factory(root.jQuery, root.utility);
  }
}(this, function (utility) {
  // CONSTANTS
  var REFERENCES_PER_PAGE = 75;
  var REQUEST_URL = '/references/recent';
  var TYPEAHEAD_OPTIONS = {
    minLength: 0,
    highlight: true,
    limit: 8
  };
    
  /**
   * Reference Widget
   * Use:  new ReferenceWidget([entity_ids], { options })
   * @param {Array|Integer|String} entityIds
   * @param {Object} userOptions
   */
  function ExistingReferenceWidget(entityIds, userOptions) {
    this.options = mergeOptions(ExistingReferenceWidget.DEFAULT_OPTIONS, userOptions);
    this.entityIds = [].concat(entityIds).map(function(n) { return Number(n); });
    this.documents = null;
    this.selection = null;
    this.render = this._render.bind(this);
    this.init();
  }

  // STATIC VALUES
  ExistingReferenceWidget.TYPEAHEAD_INPUT_ID = 'ref-widget-typeahead';
  ExistingReferenceWidget.TYPEAHEAD_INPUT_SELECTOR = '#' + ExistingReferenceWidget.TYPEAHEAD_INPUT_ID;
  ExistingReferenceWidget.DEFAULT_OPTIONS = {
    "containerDiv": "#reference-widget-container",
    "afterRender": function() {},
    "afterSelect": function() {}
  };

  /**
   * Initalize the ExistingReferenceWidget 
   */
  ExistingReferenceWidget.prototype.init = function() {
    this.getDocs().then(this.render);
  };
  
  /**
   * Replaces contents of container with a typeahead
   */
  ExistingReferenceWidget.prototype._render = function() {
    var self = this;
    window.$(this.options.containerDiv).html(this._typeaheadInput());

    // render the typeahead in to the div
    window.$(ExistingReferenceWidget.TYPEAHEAD_INPUT_SELECTOR)
      .typeahead(TYPEAHEAD_OPTIONS, this._typeaheadConfig())
      .on('typeahead:selected', function (e, datum) {
	// set 'selection' property after picked
	self.selection = datum;
	self.options.afterSelect(datum);
      })
      .on('typeahead:render', function (e) {
	// 'unselect' if suggestion is re-rendered
	self.selection = null;
      });
    
    this.options.afterRender();
  };

  ///////////////////////////
  // TYPEAHEAD COMPONENTS ///
  //////////////////////////

  /**
   * Prepares Bloodhound search with provided references data
   * @param {Array[References]} data
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
	    .filter(function(x) { return x !== null; })
	    .map(function(x) {
	      return Bloodhound.tokenizers.whitespace(x.toLowerCase());
	    })
	);
      }
    });
  }
  
  /**
   * Returns function to be used as the 'source' of typeahead 
   * see https://typeahead.js.org/examples/#default-suggestions for docs on default suggestions
   * @param {Array[References]} data
   * @returns {Function} 
   */
  function referenceSource(data) {
    var bloodhound = documentBloodhound(data);
    var defaultIds = data.slice(0,8).map(function(doc) { return doc.id; });
    return function(q, sync) {
      if (q === '') {
	sync(bloodhound.get(defaultIds));
      } else {
	bloodhound.search(q, sync);
      }
    };
  }

  /**
   * Provides a configuartion object for typeahead
   * Requires `this.documents` to be set
   * @param {Array} references
   * @returns {Object} Configuration for typeahead 
   */
  ExistingReferenceWidget.prototype._typeaheadConfig = function() {
    if (!Array.isArray(this.documents)) {
      throw 'Documents are missing or invalid :(';
    }
    
    return {
      name: 'references',
      source: referenceSource(this.documents),
      displayKey: 'name',
      templates: {
	empty: '<span class="reference-suggestion"><span class="reference-empty">No matches found</span></span>',
	suggestion: suggestion
      }
    };
  };
  

  /**
   * Retrives recent documents via an ajax call to /references/recent
   * Sets this.documents if successful.
   * @returns {Promise}
   */
  ExistingReferenceWidget.prototype.getDocs = function() {
    var self = this;
    var url = this._recentReferencesUrl();
    
    return new Promise(function(resolve, reject){
      window.$.getJSON(url)
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
  ExistingReferenceWidget.prototype._recentReferencesUrl = function() {
    var params =  window.$.param({
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
  ExistingReferenceWidget.prototype._typeaheadInput = function() {
    return window.$('<input>', {
      "type": 'text',
      "placeholder": 'Search recent references',
      "id": ExistingReferenceWidget.TYPEAHEAD_INPUT_ID,
      "class": 'reference-typeahead'
    });
  };
  

  var referenceVisitLink = [
    '<div class="reference-visit-link">',
    '<a href="{{url}}" target="_blank">',
    '<span class="glyphicon glyphicon-new-window"></span>',
    '</a></div>'
  ].join('');

  var suggestionRender = [
      '<div class="reference-suggestion" title="{{url}}">',
      referenceVisitLink,
      '<div class="reference-suggestion-name">{{name}}</div>',
      '<div class="reference-suggestion-url">{{trimUrl}}</div>',
      '</div>'
    ].join('');

  /**
   * 
   * @param {Object} doc
   * @returns {String} html for suggestion
   */
    function suggestion(doc) {
      var data = Object.assign({}, doc, {trimUrl: trimUrl(doc.url)});
      return mustache.render(suggestionRender, data)
  }


  ///////////////
  // HELPERS ///
  /////////////

  function trimUrl(url) {
    var without_schema = url.replace('https://', '').replace('http://', '');
    if (without_schema.length < 38) {
      return without_schema;
    } else {
      return (without_schema.slice(0,35) + '...');
    }
  }

  function mergeOptions(defaultOptions, provided) {
    return Boolean(provided) ? Object.assign({}, defaultOptions, provided) : defaultOptions;
  };

  function flatten(arrays) {
    return Array.prototype.concat.apply([], arrays);
  }

  return ExistingReferenceWidget;  // Return the constructor
}));
