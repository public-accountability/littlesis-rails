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
 * possible types: 'text', 'date', 'boolean', 'money'
 * @param {number} category
 */
utility.relationshipDetails = function(category) {
  // fields are common to multiple categories and are reusable
  var title = ['Title', 'description1', 'text'];
  var isCurrent = ['Is current?', 'is_current', 'boolean'];
  var startDate = ['Start date', 'start_date', 'date' ];
  var endDate = ['End date', 'end_date', 'date' ];
  
  // 
  switch(category) {
  case 1: // postition
    return [
      title, isCurrent, startDate, endDate,
      ['Board member?', 'is_board', 'boolean' ],
      ['Executive?', 'is_executive', 'boolean' ],
      ['Compensation','', 'boolean', 'money' ]
    ];
  case 2: // eduction
    return [
      ['Type', 'description1', 'text'],
      startDate, endDate,
      ['Degree', 'degree', 'text'],
      ['Field', 'education_field', 'text'],
      ['Dropout?', 'is_dropout', 'boolean']
    ];
  default:
    throw 'Invalid relationship category. It must a be a number between 1 and 12';
  }
};
