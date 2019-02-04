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


export default { range, entityLink, randomDigitStringId };
