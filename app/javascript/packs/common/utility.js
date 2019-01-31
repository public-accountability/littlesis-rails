export function entityLink (id, name, ext) {
  const baseUrl = 'https://littlesis.org';
  const primaryEntityType = ext.toLowerCase() === 'person' ? 'person' : 'org';
  const slug = id + '-'  + name.replace(' ', '_');
  return [baseUrl, primaryEntityType, slug].join('/');
};

export function range(x, toExclude) {
  var range = Array.apply(null, Array(x)).map(function (_, i) {return i;});
  if (Array.isArray(toExclude)) {
    return range.filter(function(x) { return !toExclude.includes(x); });
  } else {
    return range;    
  }
};

export default { range, entityLink };
