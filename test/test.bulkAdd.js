describe('bulkAdd', function(){
  
  describe('addRemove', function() {
    before(function() { 
      $('#test').html('<div id="table"><table><tbody></tbody></table></div>');
      sinon.stub(utility, "entityInfo").returns('Person');
    });
    after(function() {  
      utility.entityInfo.restore();
      $('#test').empty();
    });
    
    it('appends row to tbody', function() {
      expect($('tbody tr').length).to.eql(0);
      bulkAdd.appendNewRow();
      expect($('tbody tr').length).to.eql(1);
    });
  });

  describe('createTable()', function() {
    it('append tr to thead', sinon.test(function() {
      var html = this.stub($.fn, 'html');
      bulkAdd.createTable(1);
      expect(html.calledOnce).to.eql(true);
      expect(html.firstCall.args[0]).to.eql('<tr></tr>');
    }));
    
    it('appends <th> 8 times with position', sinon.test(function() {
      this.stub($.fn, 'html');
      var append = this.stub($.fn, 'append');
      bulkAdd.createTable(1);
      expect(append.callCount).to.eql(8);
    }));
    
    it('appends <th> 7 times with eduction', sinon.test(function() {
      this.stub($.fn, 'html');
      var append = this.stub($.fn, 'append');
      bulkAdd.createTable(2);
      expect(append.callCount).to.eql(7);
    }));
  });

  
  describe('relationshipSelect', function(){
    before( () => {
      var stub = sinon.stub(utility, "entityInfo");
      stub.onCall(0).returns('Org');
      stub.onCall(1).returns('Person');
    });
    
    after( () => utility.entityInfo.restore() );

    it('returns list with 9 options when entity is an org', function(){
      expect(bulkAdd.relationshipSelect().children().length).to.eql(9);
    });

    it('returns list with 12 options when entity is a person', function(){
      expect(bulkAdd.relationshipSelect().children().length).to.eql(12);
    });

  });

});
