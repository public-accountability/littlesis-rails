export class Search {
  constructor(datatable){
    let map = {
      '#datatable-type': 'types:name',
      '#datatable-industry': 'industries:name',
      '#datatable-interlock': 'interlock_ids:name',
      '#datatable-list-interlock': 'list_interlock_ids:name'
    }

    for (let key in map){
      $(key).on('change', function() {
        let val = $(this).val() ? "\\b" + $(this).val() + "\\b" : "";
        datatable.columns(map[key]).search(val, true).draw();
      })
    }

    let search = $('#datatable-search');
    search.keyup(function() {
      datatable.columns('master_search:name').search($(this).val()).draw();
    });
  }
}
