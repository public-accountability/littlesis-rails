describe('bulkAdd', function() {
  describe('relationshipDetails()', function() {
    beforeEach(function(){
      spyOn($.fn, "val").and.returnValue("1");
    });

    it('returns nested array', function(){
      expect(bulkAdd.relationshipDetails()).toBeArray();
      expect(bulkAdd.relationshipDetails()[0]).toBeArray();
      expect(bulkAdd.relationshipDetails()[0][0]).toEqual('Name');
    });

  });
});
