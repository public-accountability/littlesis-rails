export function ActionsColumn(config) {
  const serializer = new XMLSerializer()

  if ( config['editable'] ){
    return {
      data: 'actions',
      name: 'actions',
      width: '1%',
      sortable: false,
      className: 'context',
      render: function(data, type, row) {
        let remover = document.getElementById('entity_remover').content.cloneNode(true)
        remover.firstElementChild.href = row.remove_url
        return serializer.serializeToString(remover)
      }
    }
  }
}
