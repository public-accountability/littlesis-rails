describe('EntityMatcherTable', function() {

  describe("Constructor Initalization", function() {

    it('sets this.config', function(){
      let matcher = new EntityMatcherTable({"foo": 'bar'});
      expect(matcher.config).toEqual({"foo": 'bar'});
    });
    
  });


});
