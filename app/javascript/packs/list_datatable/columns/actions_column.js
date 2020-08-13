export function ActionsColumn(config) {
  if ( config['editable'] ){
    return {
      data: 'actions',
      name: 'actions',
      width: '1%',
      sortable: false,
      className: 'context',
      render: function(data, type, row) {
        return $('#entity_remover').html().replace(/XYZ/, row.list_entity_id);
      }
    }
  }
}
