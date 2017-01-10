describe('bulkAdd', function(){
  describe('createTable()', function() {
    it('adds thead and tbody', sinon.test(function() {
      var html = this.stub($.fn, 'html');
      this.stub($.fn, 'val').returns(1);
      bulkAdd.createTable();
      expect(html.calledOnce).to.eql(true);
      expect(html.firstCall.args[0]).to.eql('<thead><tr></tr></thead><tbody></tbody>');
    }));
    
    it('appends <th> 8 times with position', sinon.test(function() {
      this.stub($.fn, 'html');
      this.stub($.fn, 'val').returns(1);
      var append = this.stub($.fn, 'append');
      bulkAdd.createTable();
      expect(append.callCount).to.eql(11);
    }));
    
    it('appends <th> 7 times with eduction', sinon.test(function() {
      this.stub($.fn, 'html');
      this.stub($.fn, 'val').returns(2);
      var append = this.stub($.fn, 'append');
      bulkAdd.createTable();
      expect(append.callCount).to.eql(10);
    }));
  });


  describe('tableToJson', function(){

    before(function() {
      $('#test').html('<table><thead><tr></tr><tbody><tr></tr></tbody></table>');
      utility.range(10).forEach(function(i){
	$('#test tbody tr').append($('<td>', { text: i}));
      });
    });
    after( () => $('#test').empty() );
    
    it('returns table as json', sinon.test(function() {
      this.stub($.fn, 'val').returns(1);
      var result = bulkAdd.tableToJson('table');
      console.log(result);
      var expected = [{
	name: '0',
	blurb: '1',
	primary_ext: '2',
	description1: '3',
	is_current: null,
	start_date: '5',
	end_date: '6',
	is_board: null,
	is_executive: null,
	compensation: '9'
      }];
      expect(result).to.eql(expected);
    }));
  });

});
