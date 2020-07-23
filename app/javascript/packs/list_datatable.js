function CurrencyFormatter(){
  return Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    currencyDisplay: 'symbol'
  });
}

export default function ListDatatableLoader({config, data}){
  const PAGE_LENGTH = 100;

  const currencyFormatter = new CurrencyFormatter();

  let datatable;

  this.config = config;

  this.table = function(element){
    datatable = element.DataTable({
      data: data,
      pageLength: PAGE_LENGTH,
      columns: columnConfigs(),
      order: sortOrder()
    });

    return datatable;
  }

  this.prepareExporter = function(element, destination){
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

  this.prepareSearch = function(){
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

  this.prepareEditor = function(element, editorConstructor){
    let editor = new editorConstructor({
      ajax: config['update_path'],
      table: element,
      fields: EditorFields,
    });

    if ( config['editable'] ){
      element.on('click', editableSelector(), function() {
        editor.inline(this, { submitOnBlur: true });
      })
    }
  }

  const columnConfigs = function(){
    return [].concat(
        ...rankedTableCols(),
        NameColumn,
        DonationsColumn,
        ContextColumn(),
        ActionsColumn(),
        idColumn,
        BasicColumn('types'),
        BasicColumn('industries'),
        MasterSearchColumn(),
        BasicColumn('interlock_ids'),
        BasicColumn('list_interlock_ids')
      ).filter(col => col !== undefined);
  }

  const sortOrder = function(){
    if ( config['ranked_table'] ){
      return [[ columnConfigs().findIndex(col => col['data'] == 'default_sort_position'), 'asc' ]]
    } else {
      return [[ columnConfigs().findIndex(col => col['data'] == 'total_usd_donations'), 'desc' ]]
    }
  }

  const nameRenderer = function(row){
    let link = entityLink(row.name, row.url);
    let blurb = entityBlurb(row.blurb);
    return link + " &nbsp; " +  blurb;
  }

  const entityLink = function(name, url){
    let a = document.createElement('a');
    a.href = url;
    a.setAttribute('class', 'entity-link');
    a.innerHTML = name;
    return a.outerHTML;
  }

  const entityBlurb = function(blurb){
    let str = document.createElement('span');
    str.setAttribute('class', 'entity-blurb');
    str.innerHTML = blurb;
    return str.outerHTML
  }

  function BasicColumn(dataname, name){
    return {
      data: dataname,
      name: name || dataname,
      visible: false,
      searchable: true
    }
  }

  function ContextColumn() {
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

  function ActionsColumn() {
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

  const NameColumn = {
    data: 'name', 
    name: 'name',
    width: "30%",
    render: function(data, type, row) {
      return nameRenderer(row)
    }
  }

  const DonationsColumn = {
    data: 'total_usd_donations',
    name: 'total USD donations',
    width: "30%",
    visible: true,
    render: function(data, type, row) {
      return currencyFormatter.format(row.total_usd_donations).replace('.00', '');
    }
  }

  const idColumn = {
    data: 'id',
    name: 'id',
    visible: false,
    searchable: false
  }

  function MasterSearchColumn(){
    return {
      data: 'master_search',
      name: 'master_search',
      visible: false,
      searchable: true,
      render: function(data, type, row) {
        var keys = ['name', 'blurb', 'types', 'industries']
          return keys.map(function(key) { return row[key] }).join('  ');
      }
    }
  }

  function RankColumn(){
    return  {
      data: 'rank',
      name: 'rank',
      width: "5%",
      className: 'rank'
    }
  }

  function rankedTableCols(){
    if ( config['ranked_table'] ){
      return [
        new BasicColumn('default_sort_position'),
        new RankColumn()
      ]
    } else {
      return []
    }
  }

  const EditorFields = [
    {
      label: 'List Entity ID:',
      name: 'list_entity_id'
    },
    {
      label: 'Rank:',
      name: 'rank'
    },
    {
      label: config['context_field_name'],
      name: 'context',
      type: 'textarea',
      className: "datatable-textarea"
    },
    {
      label: 'Interlock Ids:',
      name: 'interlock_ids'
    },
    {
      label: 'List Interlock Ids:',
      name: 'list_interlock_ids'
    }
  ];

  function editableSelector(){
    return ( config['context_field_name'] ? 'tbody td.rank, tbody td.context' : 'tbody td.rank' );
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
}
