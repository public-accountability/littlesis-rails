describe('bulkAdd', function() {
  describe('relationshipDetails()', function() {
    
    describe('selected position relationship', function() {
      beforeEach(function(){
	spyOn($.fn, "val").and.returnValue("1");
      });

      it('returns nested array', function(){
	expect(bulkAdd.relationshipDetails()).toBeArray();
	expect(bulkAdd.relationshipDetails()[0]).toBeArray();
	expect(bulkAdd.relationshipDetails()[0][0]).toEqual('Name');
      });
    }); 
    
    describe('selected donation received relationship', function() {
      beforeEach(function(){
	spyOn($.fn, "val").and.returnValue("50");
      });

      it('returns nested array', function(){
	expect(bulkAdd.relationshipDetails()).toBeArray();
	expect(bulkAdd.relationshipDetails()[0]).toBeArray();
	expect(bulkAdd.relationshipDetails()[0][0]).toEqual('Name');
      });
    }); 

  });
});

/*
These are older mocha tests that need to be rewritten for jasmine in order to work.


describe('createTable()', function() {
    it('adds thead and tbody', sinon.test(function() {
      var html = this.stub($.fn, 'html');
      this.stub($.fn, 'val').returns(1);
      bulkAdd.createTable();
      expect(html.calledOnce).to.eql(true);
      expect(html.firstCall.args[0]).to.eql('<thead><tr></tr></thead><tbody></tbody>');
    }));

  describe('tableToJson', function(){
    before(function() {
      $('#test').html('<table><thead><tr></tr><tbody><tr></tr></tbody></table>');
      $('#test tbody tr').append($('<td>', { text: 'NAME'}));
      $('#test tbody tr').append($('<td>', { text: 'BLURB'}));
    });
    after( () => $('#test').empty() );
    
    it('returns table as json', sinon.test(function() {
      this.stub($.fn, 'val').returns(1);
      var result = bulkAdd.tableToJson('table', [
       	{key: 'name', type: 'text'}, 
       	{key: 'blurb', type: 'text'}
      ]);
      expect(result).to.eql([{name: 'NAME', blurb: 'BLURB' }]);
    }));
  });
  
  describe('cellValidation', function(){
    it('returns false if missing name',function(){
      var isValid = bulkAdd.cellValidation({key: 'name'}, 'cell', '');
      expect(isValid).to.eql(false);
    });

    it('returns true if contains a name',function(){
      var isValid = bulkAdd.cellValidation({key: 'name'}, 'cell', 'evil corp');
      expect(isValid).to.eql(true);
    });

    it('adds class if missing name', sinon.test(function(){
      var addClassSpy = this.spy($.fn, 'addClass');
      bulkAdd.cellValidation({key: 'name'}, sinon.stub(), '');
      expect(addClassSpy.callCount).to.eql(1);
    }));

    it('does not adds class if cell contains a name', sinon.test(function(){
      var addClassSpy = this.spy($.fn, 'addClass');
      bulkAdd.cellValidation({key: 'name'}, sinon.stub(), 'evil corp');
      expect(addClassSpy.called).to.eql(false);
    }));
    
    it('calls invalidDisplay for invalid date', sinon.test(function(){
      var addClassSpy = this.spy($.fn, 'addClass');
      bulkAdd.cellValidation({key: 'start_date', type: 'date'}, sinon.stub(), 'bad date');
      expect(addClassSpy.calledOnce).to.eql(true);
    }));
    
    it('does not call invalidDisplay for valid date', sinon.test(function() {
      var addClassSpy = this.spy($.fn, 'addClass');
      bulkAdd.cellValidation({key: 'start_date', type: 'date'}, sinon.stub(), '1999-01-01');
      expect(addClassSpy.called).to.eql(false);
    }));

    it('can handle blank values for date', sinon.test(function(){
      var addClassSpy = this.spy($.fn, 'addClass');
      bulkAdd.cellValidation({key: 'start_date', type: 'date'}, sinon.stub(), '');
      bulkAdd.cellValidation({key: 'start_date', type: 'date'}, sinon.stub(), null);
      expect(addClassSpy.called).to.eql(false);
    }));
  });


*/
