var utility = {};

/**
 * 
 * @param {Integer} id
 * @param {String} name
 * @param {String} ext
 * @returns {String} 
 */
utility.entityLink = function(id, name, ext) {
  var url = '//littlesis.org/';
  if (ext.toLowerCase() === 'person') {
    url += 'person/';
  } else {
    url += 'org/';
  }
  url += (id + '/'  + name.replace(' ', '_'));
  return url;
};


/**
 * 
 * @param {integer} x
 * @param {array} to_exclude
 * @returns {array} 
 */
utility.range = function(x, toExclude) {
  var range = Array.apply(null, Array(x)).map(function (_, i) {return i;});
  if (Array.isArray(toExclude)) {
    return range.filter(function(x) { return !toExclude.includes(x); });
  } else {
    return range;    
  }
};

/**
 * looks up entity info stored in #entity-info div 
 * @param {string} key
 * @returns {string} 
 */
utility.entityInfo = function(key) {
  return document.getElementById('entity-info').dataset[key];
};

/**
 * Relationship categories
 */
utility.relationshipCategories = [
  "",
  "Position",
  "Education (as a student)",
  "Membership",
  "Family",
  "Donation/Grant",
  "Service/Transaction",
  "Lobbying",
  "Social",
  "Professional",
  "Ownership",
  "Hierarchy",
  "Generic"
];

/**
 * Returns an nested array of [ display, fieldname, type ] 
 * possible types: 'text', 'date', 'triboolean', 'boolean', 'money', 'number'
 * @param {number} category
 */
utility.relationshipDetails = function(category) {
  // reusable fields that are common to multiple categories
  var title = ['Title', 'description1', 'text'];
  var isCurrent = ['Is current?', 'is_current', 'triboolean'];
  var startDate = ['Start date', 'start_date', 'date' ];
  var endDate = ['End date', 'end_date', 'date' ];
  var type = ['Type', 'description1', 'text'];
  var amount = ['Amount', 'amount', 'money'];
  var goods = ['Goods', 'goods', 'text'];
  var d1 = ['entity 1 is __ of entity 2', 'description1', 'text'];
  var d2 = ['entity 2 is __ of entity 1', 'description2', 'text'];
      
  switch(category) {
  case 1: // postition
    return [
      title, isCurrent, startDate, endDate,
      ['Board member?', 'is_board', 'boolean' ],
      ['Executive?', 'is_executive', 'boolean' ],
      ['Compensation','compensation', 'money' ]
    ];
  case 2: // eduction
    return [
      type, startDate, endDate,
      ['Degree', 'degree', 'text'],
      ['Field', 'education_field', 'text'],
      ['Dropout?', 'is_dropout', 'boolean']
    ];
  case 3: // members
    return [
      title, startDate, endDate, isCurrent,
      ['Membership Dues', 'membership_dues', 'money']
    ];
  case 4: // family
    return [ d1, d2, startDate, endDate, isCurrent ];
  case 5: // donation
    return [ type, amount, startDate, endDate, isCurrent, goods ];
  case 6: // transaction
    return [ d1, d2, amount, startDate, endDate, isCurrent, goods ];
  case 7: // lobby
    throw 'Lobbying relationships are not currently supposed by the bulk add tool';
  case 8: // social
    return [ d1, d2, startDate, endDate, isCurrent ];
  case 9: // professional
    return [ d1, d2, startDate, endDate, isCurrent ];
  case 10: // ownership
    return [ 
      title, startDate, endDate, isCurrent,
      [ 'Percent Stake', 'percent_stake', 'number'],
      [ 'Shares Owned', 'shares', 'number']
    ];
  case 11: // hierarchy
    return [ d1, d2, startDate, endDate, isCurrent ];
  case 12: // generic
    return [ d1, d2, startDate, endDate, isCurrent ];
  default:
    throw 'Invalid relationship category. It must be a number between 1 and 12';
  }
};

utility.validDate = function(str) {
  if (str.length === 4 && Boolean(str.match(/[0-9]{4}/))) {
    return true;
  }
  var date = str.split('-');
  if (date.length !== 3
      || date[0].length !== 4
      || date[1].length !== 2
      || date[2].length !== 2
      || Number(date[1]) > 12
      || Number(date[2]) > 31)
  {
    return false;
  }
  return true;
};

/**
   Simple url validation. Tests if it begins with 'http://' or 'https://' and is
   followed by at least one character followed by a dot followed by another character. 
   
   So yes, http://1.blah is a valid url according to these standards...we could go crazy with the regexs...https://mathiasbynens.be/demo/url-regex...but this is FINE
*/
utility.validURL = function(str) {
    var pattern = RegExp('^(https?:\/\/)(.+)[\.]{1}.+$');
    return pattern.test(str);
};


utility.validFirstAndLastName = function(str){
  // we allow suffixes like Jr. as well
  str.match(/^[a-z,.'-]+\s[a-z,.'-]+(\s[a-z,.'-]+)?$/i);
};

/**
 * Determines if the browser has the ability to open and read files
 * @returns {Boolean} 
 */
utility.browserCanOpenFiles = function() {
    return (window.File && window.FileReader && window.FileList && window.Blob);
};


// OBJECT UTILITIES

utility.get = function(obj, key) {
  var entry = utility.isObject(obj) && Object.getOwnPropertyDescriptor(obj, key);
  return entry && entry.value;
};

utility.getIn = function(obj, keys){
  return keys.reduce(
    function(acc, key){ return utility.get(acc, key); },
    obj
  );
};

utility.set = function(obj, key, value){
  var _obj = Object.assign({}, obj);
  return Object.defineProperty(_obj, key, {
    configurable: true,
    enumerable: true,
    writeable: true,
    value: value
  });
};

utility.setIn = function(obj, keys, value){
  if (keys.length === 0) {
    return value;
  } else {
    return utility.set(
      obj,
      keys[0],
      utility.setIn(
        utility.get(obj, keys[0]),
        keys.slice(1),
        value
      )
    );
  }
};

utility.delete = function(obj, keyToDelete){
  return Object.keys(obj).reduce(
    function(acc, key){
      return key === keyToDelete ?
        acc :
        utility.set(acc, key, utility.get(obj, key));
    },
    {}
  );
};

utility.deleteIn = function(obj, keys){
  var leafPath = keys.slice(0, -1);
  var leafNode = utility.getIn(obj, leafPath);
  return utility.setIn(
    obj,
    leafPath,
    utility.delete(leafNode, keys.slice(-1)[0])
  );
};

// see https://github.com/paularmstrong/normalizr
utility.normalize = function(arr){
  return arr.reduce(
    function(acc, item){ return utility.set(acc, item.id, item); },
    {}
  );
};

utility.exists = function(obj){
  return obj !== undefined && obj !== null;
};

utility.isObject = function(maybeObj){
  return maybeObj && maybeObj instanceof Object;
};

utility.isEmpty = function (obj){
  return !Object.keys(obj).length;
};

