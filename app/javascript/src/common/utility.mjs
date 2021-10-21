/**
 *
 * @param {Integer} id
 * @param {String} name
 * @param {String} ext
 * @returns {String}
 */

export function entityLink (id, name, ext) {
  const baseUrl = 'https://littlesis.org';
  const primaryEntityType = ext.toLowerCase() === 'person' ? 'person' : 'org';
  const slug = id + '-'  + name.replace(' ', '_');
  return [baseUrl, primaryEntityType, slug].join('/');
};

/**
 *
 * @param {integer} x
 * @param {array} to_exclude
 * @returns {array}
 */
export function range(x, toExclude) {
  var range = Array.apply(null, Array(x)).map(function (_, i) {return i;});
  if (Array.isArray(toExclude)) {
    return range.filter(function(x) { return !toExclude.includes(x); });
  } else {
    return range;
  }
};

/**
 * Random String of digits
 * @param {integer} n number of digits
 * @returns {String}
 */
export function randomDigitStringId(n) {
  if (typeof n === 'undefined') {
    n = 10;
  }

  else if (n > 14 || n < 1) {
    throw  "randomDigitStringId() can return at most 14 digits";
  }

  return Math.random().toString().slice(2, (2 + n));
};


/**
 * looks up entity info stored in #entity-info div
 * @param {string} key
 * @returns {string}
 */
export function entityInfo(key) {
  return document.getElementById('entity-info').dataset[key];
};


/**
 * Relationship categories
 */
const relationshipCategories = [
  "",
  "Position",
  "Education",
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
 * Extension Definition / Entity Types
 */
const extensionDefinitions = {
  "1": "Person",
  "2": "Organization",
  "3": "Political Candidate",
  "4": "Elected Representative",
  "5": "Business",
  "6": "Government Body",
  "7": "School",
  "8": "Membership Organization",
  "9": "Philanthropy",
  "10": "Other Not-for-Profit",
  "11": "Political Fundraising Committee",
  "12": "Private Company",
  "13": "Public Company",
  "14": "Industry/Trade Association",
  "15": "Law Firm",
  "16": "Lobbying Firm",
  "17": "Public Relations Firm",
  "18": "Individual Campaign Committee",
  "19": "PAC",
  "20": "Other Campaign Committee",
  "21": "Media Organization",
  "22": "Policy/Think Tank",
  "23": "Cultural/Arts",
  "24": "Social Club",
  "25": "Professional Association",
  "26": "Political Party",
  "27": "Labor Union",
  "28": "Government-Sponsored Enterprise",
  "29": "Business Person",
  "30": "Lobbyist",
  "31": "Academic",
  "32": "Media Personality",
  "33": "Consulting Firm",
  "34": "Public Intellectual",
  "35": "Public Official",
  "36": "Lawyer",
  "37": "Couple",
  "38": "Academic Research Institute",
  "39": "Government Advisory Body",
  "40": "Elite Consensus Group"
};

/**
 * Returns a nested array of [ display, fieldname, type ]
 * possible types: 'text', 'date', 'triboolean', 'boolean', 'money', 'number'
 * @param {number} category
 */
export function relationshipDetails(category) {
  // reusable fields that are common to multiple categories
  var title = ['Title', 'description1', 'text'];
  var isCurrent = ['Is current?', 'is_current', 'triboolean'];
  var startDate = ['Start date', 'start_date', 'date' ];
  var endDate = ['End date', 'end_date', 'date' ];
  var type = ['Type', 'description1', 'text'];
  var amount = ['Amount', 'amount', 'money'];
  var currency = ['Currency', 'currency', 'text'];
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
  case 2: // education
    return [
      type, startDate, endDate,
      ['Degree', 'degree', 'text'],
      ['Field', 'field', 'text'],
      ['Dropout?', 'is_dropout', 'boolean']
    ];
  case 3: // members
    return [
      title, startDate, endDate, isCurrent,
      ['Membership Dues', 'dues', 'money']
    ];
  case 4: // family
    return [ d1, d2, startDate, endDate, isCurrent ];
  case 5: // donation
    return [ type, amount, currency, startDate, endDate, isCurrent, goods ];
  case 6: // transaction
    return [ d1, d2, amount, currency, startDate, endDate, isCurrent, goods ];
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


/**
 *  Checks if string is in proper format for LittleSis Dates
 *  Example valid strings:
 *  1995-01-24
 *  2008
 *  2018-12-00
 * @param {} str
 * @returns {Boolean}
 */
export function validDate(str) {
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
export function validURL(str) {
    const pattern = RegExp('^(https?:\/\/)(.+)[\.]{1}.+$');
    return pattern.test(str);
};


export function validPersonName(str) {
  // see specs for documentation of this lovely little regex
  //return Boolean(str.match(/^[a-z,.'-]+\s[a-z,.'-]+(\s[a-z,.'-]+)?$/i));
  return Boolean(str.match(/^[^0-9\s]+\s[^0-9\s]+(\s[^0-9\s]+){0,3}$/i));
};

/**
 * Determines if the browser has the ability to open and read files
 * @returns {Boolean}
 */
export function browserCanOpenFiles() {
    return (window.File && window.FileReader && window.FileList && window.Blob);
};

/* STRING UTILITIES */

export function capitalize(str) {
  // NOTE (@aguestuser):
  // opted for util function isntead of polyfilling String.prototype
  // b/c I did the latter and it produced a fatal namespace collision with datatables.js
  return str.slice(0,1).toUpperCase() + str.slice(1);
};


const companyWords = new Set(['LLC', 'L.L.C.', 'LP', 'L.P.', 'GP', 'G.P.']);

const upperCaseCompanyWord = word => {
  let upperCaseWord = word.toUpperCase();

  return companyWords.has(upperCaseWord)
    ? upperCaseWord
    : word;
};

export function capitalizeWords(str) {
  return str
    .split(' ')
    .filter(word => !(word.trim() === ''))
    .map(word => capitalize(word.toLowerCase()))
    .map(upperCaseCompanyWord)
    .join(' ');
};


export function formatIdSelector(str) {
  if (str.slice(0,1) === '#') {
    return str;
  } else {
    return '#' + str;
  }
};

export function removeHashFromId(str) {
  return str.slice(0, 1) === '#' ? str.slice(1) : str;
};


const usdNumberFormatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

/**
 * Possible options:
 *   - Truncate --> removes cents
 * @param {String|Number} number
 * @param {Object} options
 * @returns {String}
 */
export function formatMoney(number, options = {}) {
  let formattedNumber = usdNumberFormatter.format(number);

  if (options.truncate) {
    return formattedNumber.slice(0, formattedNumber.length -3);
  } else {
    return formattedNumber;
  }
}

/**
 * Swaps two elements given their ids
 * Thanks to: https://stackoverflow.com/questions/10716986/swap-2-html-elements-and-preserve-event-listeners-on-them
 * @param {String} a ID
 * @param {String} b ID
 */
export function swapDomElementsById(aId, bId) {
  var a = document.getElementById(aId);
  var b = document.getElementById(bId);
  var temp = document.createElement("div");

  a.parentNode.insertBefore(temp, a);
  // move obj1 to right before obj2
  b.parentNode.insertBefore(a, b);
  // move obj2 to right before where obj1 used to be
  temp.parentNode.insertBefore(b, temp);
  // remove temporary marker node
  temp.parentNode.removeChild(temp);
};

/**
 * Swaps the value of two inputs given their ids
 * @param {String} a ID
 * @param {String} a ID
 */
export function swapInputTextById(aId, bId) {
  var a = document.getElementById(removeHashFromId(aId));
  var b = document.getElementById(removeHashFromId(bId));
  var temp = a.value;
  a.value = b.value;
  b.value = temp;
};


/**
 * Creates new element with text content
 *
 * @param {String} tagName
 * @param {String} text
 * @returns {Element}
 */
export function createElementWithText(tagName, text) {
  var element = document.createElement(tagName);
  element.textContent = text;
  return element;
};


/**
 * This is a simple wrapper around document.createElement
 * There are three options:
 *   - tag (defaults to div)
 *   - id
 *   - classtext
 *   - text (textContent)
 *
 * @param {} options
 * @returns {Element}
 *
 */
export function createElement(options) {
  var elementConfig = { "tag": 'div', "class": null, "id": null, "text": null};

  if (isObject(options)) {
     Object.assign(elementConfig, options);
  }

  var element = document.createElement(elementConfig.tag);

  if (elementConfig['class']) {
    element.className = elementConfig['class'];
  }

  if (elementConfig['id']) {
    element.setAttribute('id', elementConfig['id']);
  }

  if (elementConfig['text']) {
    element.textContent = elementConfig['text'];
  }

  return element;
};

/**
 * Creates an <a> with the provided href and text
 *
 * @param {String} href
 * @param {String} text
 * @returns {Element}
 */
export function createLink(href, text) {
  var a = document.createElement('a');
  a.href = href;
  if (text) {
    a.textContent = text;
  }
  return a;
};


export default {
  range, entityLink, randomDigitStringId, entityInfo,
  relationshipCategories, extensionDefinitions, relationshipDetails,
  validDate, validURL, validPersonName, browserCanOpenFiles,
  capitalize, formatIdSelector, removeHashFromId, formatMoney, capitalizeWords,
  swapDomElementsById, swapInputTextById, createElementWithText,
  createElement, createLink
};
