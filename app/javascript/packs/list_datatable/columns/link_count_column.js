export function LinkCountColumn(config){
  if ( config['sort_by'] === 'link_count' ){
    return {
      data: 'link_count',
      name: 'link count',
      width: "30%",
      visible: true,
    }
  } else {
    return
  }
}
