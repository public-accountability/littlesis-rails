import DataTableConfiguration from './datatable_configuration'

const $ = window.$

export default function (dataset) {
  $('#dataset-table').DataTable(DataTableConfiguration(dataset))


  if ($('#external-entities-match-toggle').length) {
     $("#external-entities-match-toggle input").change(function() {
       $('#dataset-table').DataTable().draw()
     })
  }

  if (dataset === 'nys_disclosure' && $('#nys-disclosure-schedule-transaction-code').length) {
    $('#nys-disclosure-schedule-transaction-code').change(function() {
      $('#dataset-table').DataTable().draw()
    })
  }
}
