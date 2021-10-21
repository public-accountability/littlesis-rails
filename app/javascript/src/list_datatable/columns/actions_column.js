export function ActionsColumn(config) {
  if ( config['editable'] ){
    return {
      data: 'actions',
      name: 'actions',
      width: '1%',
      sortable: false,
      className: 'context',
      render: function(data, type, row) {

        if (type === 'display') {
          return `<button type="button" class="btn btn-outline-warning border-0" data-action="list-datatable#removeEntity" data-list-entity-id="${row.list_entity_id}"><i class="bi bi-x-lg" style="pointer-events: none;"></i></button>`
        } else {
          return row.list_entity_id;
        }
      }
    }
  }
}
