/** A generic column template with some sensible defaults */
export function BasicColumn(dataname, name){
  return {
    data: dataname,
    name: name || dataname,
    visible: false,
    searchable: true
  }
}
