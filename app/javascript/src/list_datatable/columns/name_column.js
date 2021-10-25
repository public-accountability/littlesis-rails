export function NameColumn() {
  return {
    data: 'name',
    name: 'name',
    width: '30%',
    render: function(data, type, row) {
      return renderName(row);
    }
  }
}

const renderName = function(row) {
  let link = renderLink(row.name, row.url);
  let blurb = renderBlurb(row.blurb);
  return link + " &nbsp; " +  blurb;
}

const renderLink = function(name, url) {
  let a = document.createElement('a');
  a.href = url;
  a.setAttribute('class', 'entity-link');
  a.innerHTML = name;
  return a.outerHTML;
}

const renderBlurb = function(blurb) {
  let str = document.createElement('span');
  str.setAttribute('class', 'entity-blurb');
  str.innerHTML = blurb;
  return str.outerHTML;
}
