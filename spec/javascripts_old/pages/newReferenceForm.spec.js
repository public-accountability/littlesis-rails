describe('newReferenceForm', function() {
  const testDom = '<div id="test-dom"></div>';

  beforeEach(function(){
    $('body').append(testDom);
  });

  afterEach(function(){
    $('#test-dom').remove();
  });


  describe('rendering the form', () => {
    beforeEach(function(){
      new NewReferenceForm('#test-dom');
    });
    
    it('renders html with reference fields', () => {
      expect($('#test-dom .new-reference-form-container').length).toEqual(1);
      expect($('#test-dom .form-group').length).toEqual(6);
    });

    it('contains url input', ()=> {
      expect($('#test-dom label[for="reference-url"]').text()).toEqual('Url*');
      expect($('#test-dom input[type="url"]').length).toEqual(1);
    });

    it('contains date input', ()=> {
      expect($('#test-dom label[for="reference-date"]').text()).toEqual('Publication Date');
      expect($('#reference-date').length).toEqual(1);
    });

    it('contains excerpt input', ()=> {
      expect($('#test-dom label[for="reference-excerpt"]').text()).toEqual('Excerpt');
      expect($('#reference-excerpt').length).toEqual(1);
      expect($('#test-dom textarea').length).toEqual(1);
    });

    it('contains type select', ()=> {
      expect($('#test-dom label[for="reference-type"]').text()).toEqual('Type');
      expect($('#reference-type').length).toEqual(1);
      expect($('#reference-type option').length).toEqual(3);
      
    });


    it('contains toggle', ()=> {
      expect($('#collapseReference').length).toEqual(1);
      expect($('span.collapse-toggle').length).toEqual(2);
    });
  });


  describe('setting and get values', ()=>{

    var newRef;
    beforeEach(function(){
      newRef = new NewReferenceForm('#test-dom');
      $('input#reference-url').val('http://example.com');
      $('input#reference-name').val('example source');
      $('input#reference-date').val('1999');
      $('#reference-type option[value="3"]').prop('selected', true);
      $('#reference-excerpt').val('one two three');
    });

    it('returns object with values', () => {
      expect(newRef.value()).toEqual({
	"url": 'http://example.com',
	"name": 'example source',
	"date": '1999',
	"type": '3',
	"excerpt": 'one two three'
      });
    });
      

  });


});
