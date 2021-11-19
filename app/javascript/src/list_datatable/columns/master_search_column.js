export function MasterSearchColumn(){
  return {
    data: 'master_search',
    name: 'master_search',
    visible: false,
    searchable: true,
    render: function(data, type, row) {
      var keys = ['name', 'blurb', 'types']
      return keys.map(function(key) { return row[key] }).join('  ');
    }
  }
}
