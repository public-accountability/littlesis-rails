import { capitalizeWords } from '../common/utility'

function eeLink(external_entity_id, contents, matched = false) {
  let html = '<a href="/external_entities/' + external_entity_id + '">' + contents + '</a>'

  if (matched) {
    html += " ✔"
  }

  return html
}


const COLUMNS = {}

COLUMNS["iapd_advisors"] =  [
  {
    "data": "id",
    "orderable": false,
    "render": function(data, type, row) {
      return eeLink(row.external_entity_id, row.data.names[0], row['matched'])
    }
  },
  {
    "data": "data.latest_aum",
    "render": function(data) {
      var formatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumSignificantDigits: 3 })

      if ((data / 1000000000) >= 1) {
        return formatter.format(data / 1000000000) + ' billion'
      } else if ((data / 1000000) >= 1) {
        return  formatter.format(data / 1000000) + ' million'
      } else {
        return formatter.format(data)
      }
    },
    "orderable": true
  },
  {
    "data": "data.crd_number",
    "orderable": false,
    "render": function(data) {
      if (!data) { return '' }

      return [
        '<a target="_blank" href="https://adviserinfo.sec.gov/firm/summary/',
        data,
        '">',
        data,
        '</a>'
      ].join('')
    }
  }
]

COLUMNS["iapd_schedule_a"] =  [
  {
    "data": "id",
    "orderable": false,
    "render": function(data, type, row) {
      var last_record = row.data.records[row.data.records.length - 1]
      var html = '<a href="/external_relationships/' + row.external_relationship_id + '">' + last_record.title_or_status + '</a>'

      if(row['matched']) {
        html += " ✔"
      }

      return html
    }
  },
  {
    "data": "data.records",
    "orderable": false,
    "render": function(data, type, row) {
      return row.data.records[row.data.records.length - 1].name
    }
  },
  {
    "data": "data.advisor_name",
    "orderable": false,
    "render": function(data, type, row) {
      return [
        row.data.advisor_name,
        ' ',
        '<a target="_blank" href="https://adviserinfo.sec.gov/firm/summary/',
        row.data.advisor_crd_number,
        '">',
        '(' + row.data.advisor_crd_number + ')',
        '</a>'
      ].join('')
    }
  },
  {
    "data": "data.records",
    "orderable": false,
    "render": function(data, type, row) {
      return row.data.records[row.data.records.length - 1].acquired
    }
  }
]


COLUMNS["nycc"] =  [
  {
    "data": "data.FullName",
    "orderable": false,
    "render": function(data, type, row, meta) {
      return eeLink(row.external_entity_id, row.data.FullName, row.matched)
    }
  },
  {
    "data": "data.CouncilDistrict",
    "orderable": true,
    "render": function(district) { return district.replace('NYCC', '') }
  },
  {
    "data": "data.Party",
    "orderable": false
  }
]

COLUMNS["nys_disclosure"] =  [
  {
    "data": "id",
    "orderable": false,
    "render": function(data, type, row, meta) {
      let html = '<a href="/external_relationships/' + row.external_relationship_id + '">' + row.nice.title + '</a>'

      if(row['matched']) {
        html += " ✔"
      }

      return html
    },
  },
  {
    "data": "filer_id",
    "orderable": false,
    "render": function(data, type, row, meta) {
      return row['filer_name'] + ' (' + row['filer_id'] + ')'
    }
  },
  {
    "data": "amount",
    "orderable": true,
    "render": function(data, type, row, meta) {
      return row.nice.amount
    }
  },
  {
    "data": "date",
    "orderable": true,
    "render": function(data, type, row, meta) {
      return row.nice.date
    }
  }
]


COLUMNS["nys_filer"] = [
  {
    "data": "id",
    "orderable": false,
    "render": function(data, type, row) {
      let html = '<a href="/external_entities/' + row.external_entity_id + '">' + row.nice.name + '</a>';

      if(row['matched']) {
        html += " ✔"
      }

      return html
    }
  },
  {
    "data": "nice.committee_type",
    "orderable": false
  },
  {
    "data": "nice.office",
    "orderable": false
  }
]


COLUMNS["fec_donor"] = [
  {
    "data": "id",
    "orderable": false,
    "render": function(data, type, row) {
      return row.nice.name
    }
  },
  {
    "data": "nice.location",
  },
  {
    "data": "nice.employment",
    "orderable": false,
    "render": function(data, type, row) {
      return row.nice.employment
    }
  },
  {
    "data": "nice.contributions",
    "orderable": false,
  }
]

COLUMNS["fec_committee"] = [
  {
    "data": "dataset_id",
    "searchable": false,
    "orderable": false,
    "render": function(data, type, row) {
      return eeLink(row.external_entity_id, data, row.matched)
    }
  },
  {
    "data": "data.CMTE_NM",
    "searchable": false,
    "orderable": false
  },
  {
    "data": "data.CMTE_TP",
    "searchable": false,
    "orderable": false,
    "render": function(data) {
      return capitalizeWords(data.split('_').join(' ')).replace('Pac', 'PAC')
    }
  },
  {
    "data": "data.CMTE_ST1",
    "searchable": false,
    "orderable": false,
    "render": function(data, type, row) {
      return [
        row.data.CMTE_ST1,
        row.data.CMTE_ST2,
        row.data.CMTE_CITY,
        row.data.CMTE_ST,
        row.data.CMTE_ZIP
      ]
        .filter(Boolean)
        .filter(x => x != 'NONE')
        .join(", ")
    }
  },
  {
    "data": "data.CMTE_PTY_AFFILIATION",
    "searchable": false,
    "orderable": false
  },
  {
    "data": "data.CONNECTED_ORG_NM",
    "searchable": false,
    "orderable": false
  }
]


export default COLUMNS
