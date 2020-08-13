import { Exporter } from './list_datatable/exporter.js';
import { Search } from './list_datatable/search.js';
import { Editor } from './list_datatable/editor.js';

import { BasicColumn } from './list_datatable/columns/basic_column.js';
import { RankedTableColumns } from './list_datatable/columns/ranked_table_columns.js';
import { NameColumn } from './list_datatable/columns/name_column.js';
import { DonationsColumn } from './list_datatable/columns/donations_column.js';
import { LinkCountColumn } from './list_datatable/columns/link_count_column.js';
import { ActionsColumn } from './list_datatable/columns/actions_column.js';
import { IdColumn } from './list_datatable/columns/id_column.js';
import { MasterSearchColumn } from './list_datatable/columns/master_search_column.js';

export default function ListDatatableLoader({config, data}){
  const PAGE_LENGTH = 100;

  let datatable;

  this.table = function(element){
    datatable = element.DataTable({
      data: data,
      pageLength: PAGE_LENGTH,
      columns: columnConfigs(),
      order: sortOrder()
    });

    return datatable;
  }

  this.prepareExporter = function(element, destination) {
    return new Exporter(element, destination, config, data);
  }

  this.prepareSearch = function(){ return new Search }

  this.prepareEditor = function(element, editorConstructor){
    return new Editor(element, editorConstructor, config);
  }

  const columnConfigs = function(){
    return [].concat(
        ...RankedTableColumns(config),
        NameColumn(),
        DonationsColumn(config),
        LinkCountColumn(config),
        ActionsColumn(config),
        IdColumn,
        BasicColumn('types'),
        BasicColumn('industries'),
        MasterSearchColumn(),
        BasicColumn('interlock_ids'),
        BasicColumn('list_interlock_ids')
      ).filter(col => col !== undefined);
  }

  const sortOrder = function(){
    if( config['sort_by'] ) {
      return [[ columnConfigs().findIndex(col => col['data'] == config['sort_by']), 'desc' ]]
    } else if ( config['ranked_table'] ){
      return [[ columnConfigs().findIndex(col => col['data'] == 'default_sort_position'), 'asc' ]]
    }
  }
}
