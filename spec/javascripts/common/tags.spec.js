describe('tag module', function () {
  
  var allTags = [{
    name: 'Oil',
    description: 'flows from pipes',
    id: 1
  },{
    name: 'NYC',
    description: 'center of the universe!',
    id: 2
  }];
  
  describe('tags store operations', function (){

    it('creates a tags data structure from input', function(){
      tags.init(allTags, [1]);
      expect(tags.get()).toEqual({
	all: {
	  1: allTags[0],
	  2: allTags[1]
	},
	current: [1]
      });
    });

    it('clears store upon initialization', function(){
      tags.init(allTags, [1]);
      expect(tags.get().current).toEqual([1]);
      tags.init(allTags, [2]);
      expect(tags.get().current).toEqual([2]);
    });

    it('adds a tag', () => {
      tags.init(allTags, [1]);
      tags.add(2);
      expect(tags.get().current).toEqual([1,2]);
    });

    it('removes a tag', () => {
      tags.init(allTags, [1,2]);
      tags.remove(2);
      expect(tags.get().current).toEqual([1]);
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
	tags.init(allTags, [2]);
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
      $('body').append('<div id="container-id">');
    });

    afterEach(function(){
      $('#container-id').remove();
    });
    
    it('displays list of tags', () => {
      tags.init(allTags, [1,2], '#container-id');
      tags.render();

      expect($('#tag-list')).toExist();
      expect($('#container-id li')).toHaveLength(2);
    });

  });

  describe('editing tags', function(){

    it('shows an x inside tags that a user can remove');

    it('does not show an x inside tags that a user cannot remove');

    it('displays whitelisted tags for user to pick from');

    it('does not allow user to enter tags that are not whitelisted');

    it('stretches the bounding box to contain multiple rows of tags');  

    it('submits new tags when user clicks button');
  });
});
