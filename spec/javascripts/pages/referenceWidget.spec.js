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
      var input = referenceWidget._typeaheadInput()[0];
      expect(input.id).toEqual('ref-widget-typeahead');
    });
  });

  describe('initializing the widget', function(){
    it('is a function',function(){
      expect(referenceWidget.init).toBeFunction();
    });

    it('adds the input to the dom', function(){
      expect(elementExists(referenceWidget.TYPEAHEAD_INPUT_SELECTOR)).toBeFalse();
      referenceWidget.init('#test-dom');
      expect(elementExists(referenceWidget.TYPEAHEAD_INPUT_SELECTOR)).toBeTrue();
    });

  });
  
  
});
