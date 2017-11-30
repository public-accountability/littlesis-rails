describe('Ny Match Doantions', function(){

  var testDom =
      '<div id="test-dom">'  + 
        '<table id="donations-table"></table>' + 
      '</div>';

  beforeEach(function(){
    $('body').append(testDom);
  });

  afterEach(function(){
    $('#test-dom').remove();
  });

  describe('reviewing donations', function(){
    //new NyMatchDonations('unmatch', <%= @entity.id %> ).init();

    beforeEach(function(){
      spyOn($, "getJSON");
    });
    
    describe('init', function(){
      it('gets existing matches via ajax', function(){
	var nyMatch = new NyMatchDonations('unmatch', 123);
	nyMatch.init();
	expect($.getJSON).toHaveBeenCalledWith('/nys/contributions', {entity: 123}, jasmine.any(Function));
      });
    });
  });


  describe('matching donations', function(){
    describe('init', function(){
      beforeEach(function(){
	spyOn($, "getJSON");
      });

      it('gets potential matches via ajax', function(){
	var nyMatch = new NyMatchDonations('match', 123);
	nyMatch.init();
	expect($.getJSON).toHaveBeenCalledWith('/nys/potential_contributions', {entity: 123}, jasmine.any(Function));
      });
    });

    describe('matchRequest', function(){
      beforeEach(function(){
	spyOn($, "post").and.callFake( () => ({ "done": () => ({ "fail": () => null }) }) );
      });
      
      it('sends disclosure ids to be matched', function(){
	var entity_id = 123;
	var nyMatch = new NyMatchDonations('match', entity_id);
	var ids = [100, 200, 300];
	nyMatch.matchRequest(ids);
	var data = { payload: {disclosure_ids: ids, donor_id: entity_id } };
	expect($.post).toHaveBeenCalledWith('/nys/match_donations', data);
      });

      it('sends ny_match_ids when in unmatch mode', function(){
	var entity_id = 123;
	var nyMatch = new NyMatchDonations('unmatch', entity_id);
	var ids = [9, 8, 7];
	nyMatch.matchRequest(ids);
	var data = { payload: {ny_match_ids: ids } };
	expect($.post).toHaveBeenCalledWith('/nys/unmatch_donations', data);
      });
      
    });
  });
});
