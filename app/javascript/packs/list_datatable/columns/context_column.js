export function ContextColumn(config) {
  if ( config['include_context_col'] ){
    return {
      data: 'context',
      name: 'context',
      width: '30%',
      sortable: false,
      className: 'context'
    }
  }
}
