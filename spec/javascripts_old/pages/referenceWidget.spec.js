describe('existingReferenceWidget', function() {

  const elementExists = (selector) => Boolean($(selector).length);

  const testDom = '<div id="test-dom"><p>test dom</p></div>';

  const ajaxResult = [
    {
      "id": 1525634,
      "name": "Put a Tiger In Your Think Tank",
      "url": "http://www.motherjones.com/politics/2005/05/put-tiger-your-think-tank",
      "publication_date": null,
      "excerpt": null
    },
    {
      "id": 1535850,
      "name": "CMD Submits Evidence of Exxon Mobil Funding ALEC%u2019s Climate Change Denial to New York Attorney G",
      "url": "http://www.prwatch.org/news/2015/11/12977/Exxon-ALEC-climate-denial-investigation-new-york",
      "publication_date": null,
      "excerpt": null
    }
  ];

  beforeEach(function(){
    $('body').append(testDom);

    spyOn($, 'getJSON').and.returnValue({
      "done": function(f){
	f(ajaxResult);
      },
      "fail": function(f) { f(); }
    });
    
  });

  afterEach(function(){
    $('#test-dom').remove();
  });


  describe('creating the typeahead input', function(){
    it('is an input', function(){
      var rw = new ExistingReferenceWidget([1,2]);
      var input = rw._typeaheadInput()[0];
      expect(input.id).toEqual(ExistingReferenceWidget.TYPEAHEAD_INPUT_ID);
    });
  });

  describe('initializing the widget', function(){

    it('sets the entityIds property', function(){
      expect(
	new ExistingReferenceWidget([1,2], { containerDiv: '#test-dom'}).entityIds
      ).toEqual([1,2]);

      expect(
	new ExistingReferenceWidget(['1','2'], { containerDiv: '#test-dom'}).entityIds
      ).toEqual([1,2]);

      expect(
	new ExistingReferenceWidget('1000', { containerDiv: '#test-dom'}).entityIds
      ).toEqual([1000]);
    });


    it('adds the input to the dom', function(done){
      expect(elementExists(ExistingReferenceWidget.TYPEAHEAD_INPUT_SELECTOR)).toBeFalse();
      
      new ExistingReferenceWidget([1,2], {
	containerDiv: '#test-dom',
	afterRender: function() {
	  expect(elementExists(ExistingReferenceWidget.TYPEAHEAD_INPUT_SELECTOR)).toBeTrue();
	  done();
	}
      });
    });
  });

  describe('selecting an item', function(){
    var rw;
    beforeEach(function(done){
      rw = new ExistingReferenceWidget([1,2], {
	containerDiv: '#test-dom',
	afterRender: done
      });
    });

    it('set the value of the widget', function() {
      expect(rw.selection).toBeNull();
      $('#ref-widget-typeahead').typeahead('val', 'CMD');
      $('#ref-widget-typeahead').typeahead('open');
      expect($('.tt-suggestion').length).toEqual(1);
      $('.tt-suggestion').first().trigger('click');
      expect(rw.selection).toEqual(ajaxResult[1]);
    });
  });
  
  
});
