import Columns from './columns'
import 'select2'

export default function(dataset) {
  function modifyPayloadBeforeSubmit(d) {
    // If present, include the field "matched" along the other values sent to ther server by databases.
    if ($('#external-entities-match-toggle').length) {
      d.matched = $('#external-entities-match-toggle input:checked').val()
    } else  {
      console.error('#external-entities-match-toggle not found')
    }

    if (dataset === 'nys_disclosure' && $('#nys-disclosure-schedule-transaction-code').length) {
      d.transaction_codes = $('#nys-disclosure-schedule-transaction-code').select2('data').map(x => x.id)
    }
  }

  return {
    "processing": true,
    "serverSide": true,
    "dom": 'frtip<"clearfix">l',
    "pageLength": 10,
    "order": dataset === 'nys_dislcosure' ? [ [ 2, "desc" ] ] : undefined,
    "ajax": {
      "url": `/external_data/${dataset}`,
      "dataSrc": "data",
      "data": modifyPayloadBeforeSubmit,
    },
    "columns": Columns[dataset]
  }
}
