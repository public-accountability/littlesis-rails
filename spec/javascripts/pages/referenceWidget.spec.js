describe('referenceWidget', function() {

  const elementExists = (selector) => Boolean($(selector).length);

  const testDom = '<div id="test-dom"></div>';

  beforeEach(function(){
    $('body').append(testDom);
  });

  afterEach(function(){
    $('#test-dom').remove();
  });


  describe('creating the typeahead input', function(){
    it('is an input', function(){
      var rw = new ReferenceWidget([1,2]);
      var input = rw._typeaheadInput()[0];
      expect(input.id).toEqual('ref-widget-typeahead');
    });
  });

  describe('initializing the widget', function(){
    it('adds the input to the dom', function(){
      expect(elementExists(ReferenceWidget.TYPEAHEAD_INPUT_SELECTOR)).toBeFalse();
      new ReferenceWidget([1,2], { containerDiv: '#test-dom'});
      expect(elementExists(ReferenceWidget.TYPEAHEAD_INPUT_SELECTOR)).toBeTrue();
    });

  });
  
  
});
