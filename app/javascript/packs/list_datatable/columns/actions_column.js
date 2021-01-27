export function ActionsColumn(config) {
  if ( config['editable'] ){
    return {
      data: 'actions',
      name: 'actions',
      width: '1%',
      sortable: false,
      className: 'context',
      render: function(data, type, row) {
        const js = `LittleSis.removeListEntity('${row.remove_url}')`
        return '<a onclick="' + js + '"><span class="glyphicon glyphicon-remove"></span></a>'
      }
    }
  }
}
