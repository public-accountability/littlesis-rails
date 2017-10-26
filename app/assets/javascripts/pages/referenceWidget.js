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
  /**
   * ReferenceWideget
   * Use:  new ReferenceWidget([entity_ids], { options })
   * @param {Array} entityIds
   * @param {Object} userOptions
   */
  function ReferenceWidget(entityIds, userOptions) {
    this.options = mergeOptions(ReferenceWidget.DEFAULT_OPTIONS, userOptions);
    this._init();
  }

  // STATIC VALUES
  ReferenceWidget.TYPEAHEAD_INPUT_ID = 'ref-widget-typeahead';
  ReferenceWidget.TYPEAHEAD_INPUT_SELECTOR = '#' + ReferenceWidget.TYPEAHEAD_INPUT_ID;
  ReferenceWidget.DEFAULT_OPTIONS = { "containerDiv": "#reference-widget-container" };

  // TYPEAHEAD COMPONENTS
  var referenceSearch = new Bloodhound({
    local: ['cat', 'dog', 'elephant', 'cow'],
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    datumTokenizer: Bloodhound.tokenizers.whitespace
  });

  var datasource = { name: 'references', source: referenceSearch };

  /**
   * Initalize the ReferenceWidget 
   */
  ReferenceWidget.prototype._init = function() {
    $(this.options.containerDiv).append(this._typeaheadInput());
    $(ReferenceWidget.TYPEAHEAD_INPUT_SELECTOR).typeahead(null, datasource);
  };
  
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


  return ReferenceWidget;
}));

