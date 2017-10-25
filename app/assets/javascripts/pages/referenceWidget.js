/**
 * Widget to select an existing reference or create a new one
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    root.referenceWidget = factory(root.jQuery, root.utility);
  }
}(this, function ($, utility) {
  var TYPEAHEAD_INPUT_ID = 'ref-widget-typeahead';
  var TYPEAHEAD_INPUT_SELECTOR = '#' + TYPEAHEAD_INPUT_ID;
  
  var referenceSearch = new Bloodhound({
    local: ['cat', 'dog', 'elephant', 'cow'],
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    datumTokenizer: Bloodhound.tokenizers.whitespace
  });

  var datasource = { name: 'references', source: referenceSearch };


  /**
   * Input with id ref-widget-typeahead
   * @returns {<input>} 
   */
  function typeaheadInput() {
    return $('<input>', {
      "type": 'text',
      "placeholder": 'Select an existing reference',
      "id": TYPEAHEAD_INPUT_ID
    });
  };

  /**
   * 
   * @param {String} containerDiv 
   */
  function init(containerDiv){
    $(containerDiv).append(typeaheadInput);
    $(TYPEAHEAD_INPUT_SELECTOR).typeahead(null, datasource);
  }



   return {
    init: init,
    _typeaheadInput: typeaheadInput,
    TYPEAHEAD_INPUT_ID: TYPEAHEAD_INPUT_ID,
    TYPEAHEAD_INPUT_SELECTOR: TYPEAHEAD_INPUT_SELECTOR
  };
  
}));

