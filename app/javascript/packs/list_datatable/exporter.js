export class Exporter {
  constructor(element, destination, config, data){
    let button = $(element.html());

    $(destination).append(button);

    button.on('click', function() {
      let fields = ['id', 'name', 'blurb', 'types'];

      if ( config['ranked_table'] ) fields.unshift('rank');

      let output_data = [fields].concat(Array.prototype.slice.apply(data).map(function(d) {
        return fields.map(function(field) {
          return escapeCsv(d[field]);
        })
      }));

      window.open(exportAsCsv(output_data));
    })
  }
}

function escapeCsv(field){
  let value = field === null ? '' : field.toString();

  value = value.replace(/"/g, '""');
  if (value.search(/("|,|\n)/g) >= 0) {
    value = '"' + value + '"';      
  }
  return value;
}

function exportAsCsv(output_data){
  let mime_type = 'data:text/csv;charset=utf-8,';
  let lines = output_data.map(function(v){
    return v.join(',');
  });
  return encodeURI(mime_type + lines.join('\n'));
}
