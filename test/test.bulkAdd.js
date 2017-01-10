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
	is_current: '4',
	start_date: '5',
	end_date: '6',
	is_board: '7',
	is_executive: '8',
	compensation: '9'
      }];
      expect(result).to.eql(expected);
    }));
    
  });
  
  // describe('relationshipSelect', function(){
  //   before( () => {
  //     var stub = sinon.stub(utility, "entityInfo");
  //     stub.onCall(0).returns('Org');
  //     stub.onCall(1).returns('Person');
  //   });
    
  //   after( () => utility.entityInfo.restore() );

  //   it('returns list with 9 options when entity is an org', function(){
  //     expect(bulkAdd.relationshipSelect().children().length).to.eql(9);
  //   });

  //   it('returns list with 12 options when entity is a person', function(){
  //     expect(bulkAdd.relationshipSelect().children().length).to.eql(12);
  //   });
  // });

});
