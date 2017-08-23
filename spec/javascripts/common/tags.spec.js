describe('tag module', function () {
  
  var allTags = [{
    name: 'oil',
    description: 'flows from pipes',
    id: 1
  },{
    name: 'nyc',
    description: 'center of the universe!',
    id: 2
  },{
    name: 'finance',
    description: 'banks got bailed out, we got sold out!',
    id: 3
  }];

  var divs = {
    control: "#tags-control",
    container: "#tags-container",
    edit: "#tags-edit-button"
  };

  var divIds = Object.keys(divs).reduce(
    (acc, k) => Object.assign(acc, { [k]: divs[k].slice(1) }),
    {}
  );

  beforeEach(function(){
    $('body').append(`<div id="${divIds.container}"><br></div>`);
    $('body').append($('<button>', {id: divIds.edit}));
  });

  afterEach(function(){
    $(divs.container).remove();
    $(divs.edit).remove();
  });
  
  describe('tags store operations', function (){

    it('creates a tags data structure from input', function(){
      tags.init(allTags, [1], divs);
      expect(tags.get()).toEqual({
	all: {
	  1: allTags[0],
	  2: allTags[1],
          3: allTags[2]
	},
	current: ['1'],
        divs: divs,
        cache: '<br>'
      });
    });
    

    it('clears store upon initialization', function(){
      tags.init(allTags, [1], divs);
      expect(tags.get().current).toEqual(['1']);

      tags.init(allTags, [2], divs);
      expect(tags.get().current).toEqual(['2']);
    });

    it('adds a tag', () => {
      tags.init(allTags, [1], divs);
      tags.add(2);
      expect(tags.get().current).toEqual(['1', '2']);
    });

    it('removes a tag', () => {
      tags.init(allTags, [1,2], divs);
      tags.remove(2);
      expect(tags.get().current).toEqual(['1']);
    });

    describe('side effects', () => {

      const stubbed = ['add', 'remove', 'render', 'post'];
      let spies;
      
      beforeEach(() => {
	spies = stubbed.reduce(
	  (acc, fn) => Object.assign(acc, { [fn]: spyOn(tags, fn) }),
	  {}
	);
      });
      
      it('updates the store and syncs w/ DOM & server', () => {
	tags.init(allTags, [2], divs);
	tags.update('add', 1);
	tags.update('remove', 2);
	
	expect(spies.add).toHaveBeenCalledWith(1);
	expect(spies.remove).toHaveBeenCalledWith(2);
	expect(spies.render).toHaveBeenCalled();
	expect(spies.post).toHaveBeenCalled();
      });
    }); //end  side effects
  });
  
  describe('displaying tags', function(){

    beforeEach(function(){
      tags.init(allTags, ['1','2'], divs);
    });

    it('shows nothing new when edit not clicked', () => {
      expect($('#tags-edit-list')).not.toExist();
    });

    it('shows edit mode when edit clicked', () => {
      $(divs.edit).trigger('click');
      expect($('#tags-edit-list')).toExist();
    });
  });

  describe('editing tags', function(){

    beforeEach(function(){
      tags.init(allTags, [1,2], divs);
      tags.render();
    });
    
    it('shows an x inside tags that a user can remove', function(){
      expect($(`${divs.container} span.tag-remove-button`)).toHaveLength(2);
    });

    it('removes a tag when user clicks the remove button', function(){
      expect($(`${divs.container} li`)).toHaveLength(2);
      $($('.tag-remove-button')[0]).trigger('click');
      expect($(`${divs.container} li`)).toHaveLength(1);
    });

    it('adds a valid tag from user input', () => {
      expect($(`${divs.container} li`)).toHaveLength(2);
      $('#tags-input').val('finance'); // --> tag
      $('#tags-input').trigger({ type: 'keypress', keyCode: 13});
      expect($(`${divs.container} li`)).toHaveLength(3);
    });

    it('does nothing if user enters invalid tag', () => {
      expect($(`${divs.container} li`)).toHaveLength(2);
      $('#tags-input').val('foobar');
      $('#tags-input').trigger({ type: 'keypress', keyCode: 13});
      expect($(`${divs.container} li`)).toHaveLength(2);
    });

    it('does nothing if user enters duplicate tag', () => {
      expect($(`${divs.container} li`)).toHaveLength(2);

      $('#tags-input').val('finance');
      $('#tags-input').trigger({ type: 'keypress', keyCode: 13});
      expect($(`${divs.container} li`)).toHaveLength(3);

      $('#tags-input').val('finance');
      $('#tags-input').trigger({ type: 'keypress', keyCode: 13});
      expect($(`${divs.container} li`)).toHaveLength(3);
    });
    
    it('does not allow user to enter tags that are not whitelisted');

    it('stretches the bounding box to contain multiple rows of tags');  

    it('restores old tags if user clicks cancel');

    it('refreshes page with new tags if user clicks save');

    // pending permissions card
    it('does not show an x inside tags that a user cannot remove');
    it('does not show tag options to a user who may not tag');
  });

});
