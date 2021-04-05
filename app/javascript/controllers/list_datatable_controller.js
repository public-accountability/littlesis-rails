import { Controller } from 'stimulus'
import datatable from 'datatables.net'

import { Search } from 'packs/list_datatable/search.js'
import { BasicColumn } from 'packs/list_datatable/columns/basic_column.js'
import { RankedTableColumns } from 'packs/list_datatable/columns/ranked_table_columns.js'
import { NameColumn } from 'packs/list_datatable/columns/name_column.js'
import { DonationsColumn } from 'packs/list_datatable/columns/donations_column.js'
import { LinkCountColumn } from 'packs/list_datatable/columns/link_count_column.js'
import { ActionsColumn } from 'packs/list_datatable/columns/actions_column.js'
import { IdColumn } from 'packs/list_datatable/columns/id_column.js'
import { MasterSearchColumn } from 'packs/list_datatable/columns/master_search_column.js'

export default class extends Controller {
  static values = { config: Object, data: Array, tableId: String, pageLength: Number }

  initialize() {
    const config = this.configValue
    const columns = columnConfigs(config)

    let datatable = $(this.tableIdValue).DataTable({
      data: this.dataValue,
      pageLength: this.pageLengthValue,
      columns: columnConfigs(config),
      order: sortOrder(columns, config)
    })
    new Search(datatable)
  }

  exportCsv() {
    let fields = ['id', 'name', 'blurb', 'types']

    if ( this.configValue['ranked_table'] ) fields.unshift('rank')

    let output_data = [fields].concat(Array.prototype.slice.apply(this.dataValue).map(function(d) {
      return fields.map(function(field) {
        return escapeCsv(d[field])
      })
    }))

    window.open(generateCsvFile(output_data))
  }
}

function sortOrder(columns, config) {
  if ( config['sort_by'] ) {
    return [[ columns.findIndex(col => col['data'] == config['sort_by']), 'desc' ]]
  } else if ( config['ranked_table'] ) {
    return [[ columns.findIndex(col => col['data'] == 'default_sort_position'), 'asc' ]]
  } else {
    return
  }
}

function columnConfigs(config) {
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
    ).filter(col => col !== undefined)
}

function escapeCsv(field) {
  let value = field === null ? '' : field.toString()

  value = value.replace(/"/g, '""')
  if (value.search(/("|,|\n)/g) >= 0) {
    value = '"' + value + '"' 
  }
  return value
}

function generateCsvFile(output_data) {
  let mime_type = 'data:text/csv;charset=utf-8,'
  let lines = output_data.map(function(v){
    return v.join(',')
  })
  return encodeURI(mime_type + lines.join('\n'))
}
