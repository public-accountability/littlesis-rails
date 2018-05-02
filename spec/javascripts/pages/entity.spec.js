describe('entity', function () {

  const testDom = `<div id="test-dom">
                     <div id="editable-blurb">
                       <span id="entity-blurb-text">blurb goes here</span>
                       <span id="entity-blurb-pencil"><button>edit</button></span>
                     </div>
                   </div>`;

  beforeEach(function(){
    $('body').append(testDom);
    entity.editableBlurb();
  });

  afterEach(function(){
    $('#test-dom').remove();
  });

    
  describe('editing blurb in place', () => {

    beforeEach(() => {
      spyOn(api, 'addBlurbToEntity');
      spyOn(utility, 'entityInfo').and.returnValue('123');
    });

    it('clicking on pencil replaces text with input', () => {
      expect($('#entity-blurb-text').html()).toEqual('blurb goes here');
      expect($('#entity-blurb-text input').length).toEqual(0);
      $('#entity-blurb-pencil').trigger('click');
      expect($('#entity-blurb-text input').length).toEqual(1);
    });

    it('clicking on pencil hides pencil button', () => {
      expect($('#entity-blurb-pencil')).toBeVisible();
      $('#entity-blurb-pencil').trigger('click');
      expect($('#entity-blurb-pencil')).not.toBeVisible();
    });

    it('submit request to server', () => {
      $('#entity-blurb-pencil').trigger('click');
      $('#entity-blurb-text input').val('updating');
      var e = $.Event( 'keyup', { which: 13 } );
      $('#entity-blurb-text input').trigger(e);
      expect(api.addBlurbToEntity).toHaveBeenCalled();
    });

  });

});
