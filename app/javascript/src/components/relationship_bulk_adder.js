import Mustache from 'mustache'
import Papa from 'papaparse'
import { saveAs } from 'file-saver'
import utility from '../common/utility.mjs'
import 'select2'

/**

  Inspiration: https://codepen.io/ashblue/pen/mCtuA

*/
export default function RelationshipBulkAdder() {
  // Does the user have bulk permissions?
  // All users may submit up to 8
  var USER_HAS_BULK_PERMISSIONS = null
  var AUTOCOMPLETE_MODE = true
  var NOTES_MODE = false
  var MATCHING_MODE = false
  var MATCHING_INDEX = null

  // Retrieves selected cateogry and converts 50 and 51 to 5
  function realCategoryId() {
    var category = Number($('#relationship-cat-select option:selected').val())

    // 50 -> Donations Recieved
    // 51 -> Donations Given
    // 30 -> Memberships
    // 31 -> Members
    if (category === 50 || category === 51) {
      return 5
    }
    else if (category === 30 || category === 31) {
      return 3
    } else {
      return category
    }
  }

  // Creates table structure based on category id. The number and types of columns vary by
  // relationship type. See utility.js for more information
  // -> [[]]
  function relationshipDetails() {
    var entityColumns = [ [ 'Name', 'name', 'text'], ['Blurb', 'blurb', 'text'], ['Entity type', 'primary_ext', 'select'] ]
    var notes = [ ['Notes', 'notes', 'text' ] ]
    return entityColumns.concat(utility.relationshipDetails(realCategoryId())).concat(notes)
  }

  // -> [ {} ]
  // same information as above represented as an object.
  function relationshipDetailsAsObject() {
    return relationshipDetails().map(function(x) {
      return {
        display: x[0],
        key: x[1],
        type: x[2]
      }
    })
  }

  /* CREATE TABLE  */

  function cssForNotesColumn(col) {
    if (col[1] === 'notes' && !NOTES_MODE) {
      return { display: 'none' }
    } else if (col[1] === 'name') {
      return {
        "min-width": '175px'
      }
    } else {
      return {}
    }
  }

  // Adds <th> with title to table header
  // [] ->
  function addColToThead(col) {
    $('#table thead tr').append(
      $('<th>', {
        text: col[0],
        data: { 'colName': col[1], 'colType': col[2] },
        css: cssForNotesColumn(col)
      })
    )
  }

  // => <Span>
  function addRowIcon() {
    return $('<span>', {class: 'table-add', title: 'add a new row to the table'})
      .append( $('<i>', {class: 'bi bi-plus-lg'}) )
      .append( $('<span>', {text: 'Add a row', class: 'cursor-pointer'}))
  }

  function entityMatchBtn() {
    return $('<button>', {
      text: 'Match names',
      class: 'btn btn-primary m-right-1em entity-match-btn',
      click: function() {
        if (!$(this).hasClass('matching-mode')) {
          // enable matching mode
          MATCHING_MODE = true
            MATCHING_INDEX = 0
            $(this).addClass('matching-mode')
            $(this).addClass('active')
            $(this).text('Cancel matching')
            entityMatch()
        } else {
          // stop matching
          MATCHING_MODE = false
            MATCHING_INDEX = null
            clearMatchingTable()
            $(this).removeClass('matching-mode')
            $(this).removeClass('active')
            $(this).text('Match names')
        }
      }
    })
  }

  function exampleRow(category) {
    switch(Number(category)) {
      case 1:
        return [ 'Rex Tillerson', 'Secretary of state', 'Person', 'CEO', 'N', '', '', '', 'YES', '', '' ]
      case 2:
        if (utility.entityInfo('entitytype') === 'Person') {
          return [ 'Unversity Name', '', 'Org', '', '1996', '2000', 'Graduate', 'Forestry', 'N', '']
        } else {
          return [ 'Example Person', 'One Sentence about them', 'Person', 'Undergraduate', '1985-01-01', '1990-12-01', 'BA', 'physics', '', '']
        }
      case 3:
        return [ "Oil Company", "The largest oil company in the world", "Org", "", '', '', '', '1000000', '' ]
      case 4:
        return [ 'Jane Doe', 'About Jane...', 'Person', '', '', '', '' ]
      case 5:
        return [ 'Mr. Big Donor', 'Hedge fund manager', 'Person', 'Campaign Contribution', '250000', 'usd', '2017-05-01', '2017-05-01', '', '', '' ]
      case 6:
        return [ 'Company X', '', 'Org', 'sold real estate', 'bought real estate', '', '', '1996-10-01', '', '', '', '', '']
      case 8:
        return [ 'Jane Doe', 'About Jane...', 'Person', 'Friend', 'Friend', '2000-01-01', '2015-04-15', 'NO', '' ]
      case 9:
        return [ 'Jane Doe', 'About Jane...', 'Person', 'Business Partner', 'Business Partner', '2000-01-01', '2015-04-15', 'NO', '' ]
      case 10:
        return [ 'Company X', '', 'Org', '', '1968', '2015', 'N', '25', '', '']
      case 11:
        return [ 'Company X', '', 'Org', 'Child Company', 'Parent Company', '1996-01-01', '', 'Y', '']
      case 12:
        return [ 'Jane Doe', 'About Jane...', 'Person', "Entity1 is X of Jane", "Jane is Y of entity1", '2000', '2001', '', '']
      default:
        throw 'Invalid Relationship category'
    }
  }

  // => <Button>
  // Returns button that, when clicked, saves a csv file with the correct headers
  // for the chosen relationship type
  function sampleCSVLink() {
    return $('<button>', {
      text: 'download sample csv',
      class: 'btn btn-primary mr-2',
      click: function() {
        var headers = relationshipDetails().map(function(x) {
          return x[1]
        }).join(',')
        var data = headers + "\n" + exampleRow(realCategoryId()).join(',')
        var blob = new Blob([data], {type: "text/plain;charset=utf-8"})
        var fileName = utility.relationshipCategories[realCategoryId()] + '.csv'
        saveAs(blob, fileName)
      }
    })
  }

  // -> <Caption>
  function tableCaption(){
    return $('<caption>')
      .append(addRowIcon())
      .append( $('<input>', {id: 'csv-file'}).attr('type', 'file'))
      .append( $('<div>', { class: 'float-right'}).append(sampleCSVLink()).append(entityMatchBtn()) )


  }

  function createTableHeader() {
    relationshipDetails().forEach(addColToThead)
    $('#table thead tr').append('<th>Delete</th>')
  }

  // Creates empty table based o the selected category
  function createTable() {
    $('#table table')
      .empty()
      .append(tableCaption())
      .append('<thead><tr></tr></thead><tbody></tbody>')

    createTableHeader()
    newBlankRow() // initialize table with a new blank row
    readCSVFileListener('csv-file') // handle file uploads to #csv-file
  }

  /* FIND SIMILAR RELATIONSHIPS */

  var relationshipAlertTemplate = '<p>A similar relationship was found in the littlesis database. Are you <em>sure</em> you want to create another one?</p><p><a href="{{url}}" target="_blank">Click here</a> to view the relationship.</p>'

  // input: [] -> <div>
  function similarRelationshipAlert(relationships) {
    return $('<div>', { "style": "position: relative" })
      .append(
        $('<span>', {
          "class": "bi bi-exclamation-triangle similar-relationships-alert",
          "title": "Similar relationships exist!",
          "aria-hidden": true,
          "fadeIn": { duration: 500 },
          "popover": {
            content: Mustache.render(relationshipAlertTemplate, relationships[0]),
            container: 'body',
            trigger: 'click',
            placement: 'auto',
            html: true
          }
        })
      )
  }

  // http request to /relationships/find_similar and
  // displays an alert if a similar relationship is found
  // Input: <td>, Int
  function lookForSimilarRelationship(cell, entity2_id) {
    var selectedCategoryId = Number($('#relationship-cat-select option:selected').val())
    var e1Id = (selectedCategoryId === 50) ? entity2_id : utility.entityInfo('entityid')
    var e2Id = (selectedCategoryId === 50) ? utility.entityInfo('entityid') : entity2_id

    var request = { entity1_id: e1Id,
      entity2_id: e2Id,
      category_id: realCategoryId() }

    $.getJSON('/relationships/find_similar', request)
      .done(function(relationships){
        if (relationships.length > 0) {
          cell.prepend(similarRelationshipAlert(relationships))
        }
      })
      .fail(function(){
        console.error('ajax request to /relationships/find_similar failed')
      })
  }

  /* ENTITY SEARCH AUTOCOMPLETE */

  // http request to /search/entity
  // query, callback
  // results: [{}]
  function searchRequest(text, callback) {
    $.getJSON('/search/entity', {
      num: 10,
      q: text,
      return_type: 'simple'
    })
    .done(function(result){
      callback(result.map(function(entity){
        // set the value field to be the name for jquery autocomplete
        return Object.assign({value: entity.name }, entity)
      }))
    })
    .fail(function() {
      callback([])
    })
  }

  // After selecting an entity from the autocomplete or via the matching table:
  //  - adds name and link to cell
  //  - stores entityid in dataset
  //  - sets blurb and type
  //  - makes name, blurb, and type not editable
  //  - adds reset button
  //  - searches for similar relationships via ajax
  function entitySelect(cell, entity) {
    //  requires order of table to be: name -> blurb -> entityType
    var blurb = cell.next()
    var entityType = blurb.next()
    // add link to cell
    cell.html( $('<a>', { href: entity.url, text: entity.name, target: '_blank' }))
    cell.attr('contenteditable', 'false')
    // store entity id in dataset
    cell.data('entityid', entity.id)
    // add reset-field option
    cell.append(
      $('<span>', {
        'class': 'bi bi-x reset-name',
        click: function() {
          cell.empty()  // empty the cell
          blurb.empty() // empty blurb
          // make both name and blurb cells editable
          cell.attr('contenteditable', 'true')
          blurb.attr('contenteditable', 'true')
          cell.data('entityid', null) // remove the entity id
          // Remove the similar relationship alert (if it exists)
          cell.parents('tr').find('.similar-relationships-alert').remove()
          // Remove the popover if it's left open
          cell.parents('tr').find('.popover').remove()
        }
      })
    )

    blurb.text(entity.blurb ? entity.blurb : '')
    blurb.attr('contenteditable', 'false') // disable editing of blurb
    entityType.find('select').val(entity.primary_ext)
    lookForSimilarRelationship(cell, entity.id)
  }


  var entityAutocompleteSelect2Configuration = {
    allowClear: true,
    minimumInputLength: 3,
    placeholder: "Example Person",
    ajax: {
      dataType: 'json',
      url: '/search/entity',
      data: function(params) {
        return { q: params.term, num: 10 }
      },
      processResults: function(data) {
        return {
          results: data.map(function(entity) {
            return {
              id: entity.id,
              text: entity.name,
              entity: entity
            }
          })
        }
      }
    }
  }

  /* ROW ELEMENTS */

  function primaryExtRadioButtons() {
    // Using selectpicker with multiple and max-options 1 in order to get the
    // 'Nothing selected' message displayed.
    return $('<select>', {
    }).append('<option></option><option>Org</option><option>Person</option>')
  }

  function currencySelect() {
    var template = $('.currency-selector')[0]
    return template.content.cloneNode(true)
  }

  // trio Boolean Helper
  // .create(option) => return new button element
  // .value(<element>) -> returns selected button
  // .update(<element>, status) => sets status of button set
  var triBooleanButton =  {
    // str -> <Button>
    create: function(option) {
      return $('<button>', {
        text: option,
        class: (option === '?') ? 'btn btn-primary active' : 'btn btn-primary',
        value: option,
        click: function(){
          $(this).addClass("active").siblings().removeClass("active")
        }
      })
    },
    // <td> -> Str
    value: function(td) {

      return td.find('button.active').text()
    },
    // <td>, Str -> updates the button group inside the provided element
    update: function(td, status) {
      if (!['Y', 'N', '?'].includes(status)) { throw "status must be 'Y', 'N', or '?'" }
      td.find('button[value="' + status + '"]').addClass('active').siblings().removeClass("active")
    }
  }

  function triBooleanButtonSet() {
    return ['Y', 'N', '?'].reduce(function(groupDiv, opt) {
      return groupDiv.append(triBooleanButton.create(opt))
    }, $('<div>', {class: 'btn-group btn-group-sm', role: 'group' }))
  }

  // generates <td> for new row
  // [] -> Element
  function td(col) {
    let td
    if (col[2] === 'boolean') {  // boolean column
      td = $('<td>').append('<input type="checkbox">')  // include checkbox
    } else if (col[2] === 'triboolean') { // tri-boolean column
      td = $('<td class="tri-boolean">').append(triBooleanButtonSet())
    } else if (col[1] === 'name') {
      if (AUTOCOMPLETE_MODE) {
        td = '<td><select class="entity-autocomplete" style="width: 100%"></select></td>'
      } else {
        td = $('<td>', { contenteditable: 'true'})
      }
    } else if (col[1] === 'primary_ext') {
      td = $('<td>').append(primaryExtRadioButtons())
    } else if (col[1] === 'currency') {
      td = $('<td>').append(currencySelect())
    } else if (col[1] === 'notes') {
      td = $('<td>', { css: cssForNotesColumn(col), contenteditable: 'true' })
    } else {
      td = $('<td>', { contenteditable: 'true'}) // editable column
    }
    return td
  }

  // Adds a new blank row to the table
  // Returns the newly created row
  function newBlankRow() {
    // Unless the user has bulk permissions they are limited to
    // bulk adding 8 rows at once
    if ($('#table tbody tr').length >= 8 && !USER_HAS_BULK_PERMISSIONS) {
      limitAlert()
    } else {
      var removeTd = $('<td>').append('<span class="table-remove bi bi-x-lg"></span>')
      var row = $('<tr>').append(relationshipDetails().map(td).concat(removeTd))
      $('#table tbody').append(row)
      // Because we create the select after the dom has loaded, we must initialize it here:
      $('select.entity-autocomplete').select2(entityAutocompleteSelect2Configuration)
      $('select.entity-autocomplete').on('change', function(){
        var selection = $(this).select2('data')[0]

        if (selection) {
          $(this).closest('td').next().next().find('select').val(selection.entity.primary_ext)
          lookForSimilarRelationship($(this).closest('td'), selection.entity.id)
        }
      })
      return row
    }
  }

  /* EXTRACT AND SET ROW DATA */

  // This returns the cell data
  // Most types simply need to return the text inside the element.
  // Three exceptions: checkboxes, "tribooleans", and <select>'s
  function extractCellData(cell, rowInfo) {
    let data;

    if (rowInfo.type === 'boolean') {
      // Technically we should allow three values for this field: true, false, and null.
      // However, to keep things simple, right now the false/un-checked state defaults to null
      // So in this tool there is no way of saying that a person is NOT a board member.
      data = cell.find('input').is(':checked') ? true : null
    } else if (rowInfo.type === 'triboolean' ) {
      data = triBooleanButton.value(cell)
    } else if (rowInfo.type === 'select') {
      var val = cell.find('select').val()
      data = val ? val : null
    } else if (rowInfo.key === 'name') {
      if (cell.find('select').length) {
        var selection = cell.find('select').select2('data')[0]
        if (selection) {
          data = selection.id  // use entity id
        } else {
          data = null // no entity selected
        }
      } else if (cell.data('entityid')) { // selection matched w/ match names
        data = Number(cell.data('entityid'))
      } else {
        data = (cell.text() === '') ? null : cell.text()
      }
    } else {
      data = (cell.text() === '') ? null : cell.text()
    }

    return data
  }

  var YES_VALUES = [ 1, '1', 'yes', 'Yes', 'YES', 'y', 'Y', true, 'true', 't', 'T', 'True', 'TRUE']
  var NO_VALUES = [ 0, '0', 'no', 'No', 'NO', 'n', 'N', false, 'false', 'f', 'F', 'False', 'FALSE']
  var ORG_VALUES = [ 'org', 'Org', 'ORG', 'organization', 'Organization', 'ORGANIZATION', 'o', 'O' ]
  var PERSON_VALUES = [ 'person', 'Person', 'PERSON', 'p', 'P', 'per', 'PER', 'capitalist pig']

  // This updates the cell with the provided value
  // Similar to extractCellData, but it sets
  // the values of the cells instead of extracting them
  // input: <Td>, {relationshipDetailsAsObject}, any
  function updateCellData(cell, rowInfo, value) {
    if (rowInfo.type === 'boolean') {

      if (YES_VALUES.includes(value)) {
        cell.find('input').prop('checked', true)
      }

    } else if (rowInfo.type === 'triboolean') {

      if (YES_VALUES.includes(value)) {
        triBooleanButton.update(cell, 'Y')
      } else if (NO_VALUES.includes(value)) {
        triBooleanButton.update(cell, 'N')
      } else {
        triBooleanButton.update(cell, '?')
      }


    } else if (rowInfo.type === 'select') {

      if (rowInfo.key === 'primary_ext') {
        if (ORG_VALUES.includes(value)) {
          cell.find('select').val('Org')
        } else if (PERSON_VALUES.includes(value)) {
          cell.find('select').val('Person')
        }
      }

    } else if (rowInfo.key === 'name') {
      // You can provide the id of a littlesis entity as a name
      if (Number.isInteger(Number(value))) {
        cell.data('entityid', Number(value))
      }

      cell.text(value)

    } else {
      cell.text(value)
    }
  }

  //  [{}], element -> {}
  function rowToJson(tableDetails, row) {
    var obj = {}
    tableDetails.forEach(function(rowInfo,i) {
      var cell = $(row).find('td:nth-child(' + (i + 1) + ')')

      if (rowInfo.key === 'notes' && !NOTES_MODE) {
        // do NOT include the notes unless NOTES MODE is activated
      } else {
        obj[rowInfo.key] = extractCellData(cell, rowInfo)
      }

    })
    return obj
  }

  // str, [ {} ] -> [ {} ]
  // columns should be relationshipDetailsAsObject()
  // Given the selector of a <table> and it's associated column data
  // it returns the data as an array of objects
  function tableToJson(selector, columns) {
    var _rowToJson = rowToJson.bind(null, columns)
      return $(selector + ' tbody tr').map(function(){
        return _rowToJson(this)
      }).toArray()
  }

  // <td> Element -> false
  // displays validations and return false;
  function invalidDisplay(element) {
    $(element).addClass('bg-warning')
      return false
  }

  // input: arr, element, function
  // calls the provided function on each cell in the row with these args:
  // rowInfo ({}), cell (element), cellData (various)
  function traverseRow(columns, row, func) {
    columns.forEach(function(rowInfo, i){
      var cell = $(row).find('td:nth-child(' + (i + 1) + ')')
      var cellData = extractCellData(cell, rowInfo.type)
      func(rowInfo, cell, cellData)
    })
  }

  // Calls invalidDisplay  for invalid cells and returns false;
  // Otherwise it returns true
  // {}, element, * -> boolean
  function cellValidation(rowInfo, cell, cellData) {
    if (['name', 'primary_ext'].includes(rowInfo.key) && !cellData) {
      console.log(rowInfo.key + ' is blank')
        return invalidDisplay(cell)
    }
    if (cellData && rowInfo.type === 'date' && !utility.validDate(cellData)) {
      console.log(cellData + ' is an invalid date')
        return invalidDisplay(cell)
    }
    return true
  }

  // an indicator that can only go from true to false.
  function ValidFlag() {
    this.status = true
    this.setStatus = function(input) {
      if (!input) { this.status = false }
    }
  }

  // Verifies that each cell is valid
  // str -> boolean
  function validate(selector) {
    var validFlag = new ValidFlag()
    var columns = relationshipDetailsAsObject()
    // for each row
    $(selector + ' tbody tr').each(function(){
      // for each cell in the row
      traverseRow(columns, this, function(rowInfo, cell, cellData){
        // highlighed cell if invalid and return status
        validFlag.setStatus(cellValidation(rowInfo, cell, cellData))
      })
    })
    return validFlag.status
  }

  function isRowBlank(rowObj) {
    return Object.keys(rowObj)
      .map(function(key) {
        // a new blank row has every value set to null except for is_current which equals '?'
        return (key === 'is_current' && rowObj[key] === '?') ? null : rowObj[key]
      }).filter(function(x) {
        return x !== null
      }).length == 0
  }

  function removeBlankRows() {
    tableToJson('#table', relationshipDetailsAsObject())
      .reduce(function(acc, rowObj, i) {
        return isRowBlank(rowObj) ? acc.concat($("#table tbody tr").get(i)) : acc
      }, []).forEach(function(elem) {
        elem.parentNode.removeChild(elem)
      })
  }

  function showAlert(message, alertType) {
    var template = '<div class="alert alert-dismissible {{alertType}}" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>{{message}}</div>'
    var html = Mustache.render(template, { "alertType": alertType, "message": message })
    $('#alert-container').html(html)
  }

  function limitAlert() {
    showAlert('You are only allowed to bulk upload 8 relationships at a time. <a href="/contact" class="alert-link">Contact us</a> if you\'d like to bulk add more than 8 relationships at once.', 'alert-danger')
  }

  function validateReference() {
    $('#alert-container').empty()
    var url = document.getElementById('reference-url')
    if (url.validity.valid) {
      return true
    } else {
      showAlert('Please enter in a valid source url', 'alert-danger')
      return false
    }
  }

  /* SUBMIT DATA*/

  function submit() {
    if (validateReference()) {
      $('.bg-warning').removeClass('bg-warning')
      if ( validate('#table') ) {
        submitRequest()
      } else {
        showAlert('Some cells are missing information or invalid!')
      }
    }
  }

  // data format:
  // {
  //   entity1_id: int,
  //   category_id: int,
  //   reference: {
  //     url: str
  //     name: str
  //   }
  //   relationships: [{}]
  // }
  function prepareTableData(data) {
    var entity1_id = utility.entityInfo('entityid')
    var category_id = Number($('#relationship-cat-select option:selected').val())
    var reference = {
      'url': $('#reference-url').val(),
      'name': $('#reference-name').val()
    }
    return {
      entity1_id: entity1_id,
      category_id: category_id,
      reference: reference,
      relationships: data
    }
  }

  function repopulateTable(errors) {
    $('.result-mode').hide()
    $('.create-mode').show()
    createTable()

    errors.map(function(err) { showAlert(err.errorMessage, 'alert-danger') })

    // remove the errors messages
    var relationships = errors.map(function(err) {
      delete err.errorMessage
      return err
    })

    // The array of objects is turned into a string
    // just to be, moments later, parsed again.
    // It allows us to re-use the csvToTable function.
    csvToTable(Papa.unparse(relationships))
  }

  var afterRequest = {

    // summary text with relationship and error count
    info: function(data) {
      var text = data.relationships.length.toString() + ' Relationships were created  / ' +  data.errors.length.toString() + ' Errors occured'
      return $('<div>', {class: 'col-sm-12' }).append($('<h4>', {text: text}))
    },

    // one list-group-item of a relationship
    relationshipDisplay: function(relationship) {
      return $('<a>', {href: relationship.url, class: 'list-group-item', target: '_blank'})
        .append($('<p>', {class: 'list-group-item-text', text: relationship.name }))
    },

    errorDisplay: function(errors) {
      return $('<div>', {class: 'col-sm-8'})
        .append(
          $('<p>', {
            class: 'cursor-pointer top-1em',
            text: 'click here to repopulate the table with the relationships that failed',
            click: function() { repopulateTable(errors) }
          }))
    },

    // show relationship list + summary text
    display: function(data) {
      $('.result-mode').show()
      var $results = $('#results')
        .empty()
        .append(afterRequest.info(data))

      if (data.relationships.length > 0) {
        var container = $('<div>', {class: 'col-sm-8'}).append( $('<h3>', {class: '', text: 'New relationships'}))
        var relationships = data.relationships.reduce(function(listGroup, relationship) {
          return listGroup.append(afterRequest.relationshipDisplay(relationship))
        }, $('<div>', {class: 'list-group'}))

        $results.append(container.append(relationships))
      }

      if (data.errors.length > 0) {
        $results.append(afterRequest.errorDisplay(data.errors))
      }
    },

    success: function(data) {
      $('#spin-me-round-like-a-record').hide()
      $('#table table').empty()
      if (data.errors.length === 0) {
        showAlert('The request was successful!', 'alert-success')
      } else if (data.relationships.length === 0) {
        data.errors.map(function(err) { showAlert(err.errorMessage, 'alert-danger') })
      } else {
        showAlert('Some relationships could not be created', 'alert-warning')
        data.errors.map(function(err) { showAlert(err.errorMessage, 'alert-danger') })
      }
      afterRequest.display(data)
    },

    error: function() {
      $('#spin-me-round-like-a-record').hide()
      alert('something went wrong :(')
    }
  }

  // Sends the data for submission
  function submitRequest() {
    $('#spin-me-round-like-a-record').show()
    $('.create-mode').hide()
    var data = prepareTableData(tableToJson('#table', relationshipDetailsAsObject()))
    $.ajax({
      method: 'POST',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      url: '/relationships/bulk_add',
      contentType: 'application/json',
      dataType: "json",
      data: JSON.stringify(data),
      success: afterRequest.success,
      error: afterRequest.error
    })
  }

  /* READ FROM CSV */

  // Takes a CSV string and writes result to the table
  // see github.com/mholt/PapaParse for PapeParse library docs
  function csvToTable(csvStr) {

    // csv.data contains an array of objects where the keys are the same as rowInfo.key
    var csv = Papa.parse(csvStr, { header: true, skipEmptyLines: true})
    var columns = relationshipDetailsAsObject()

    if (csv.data.length > 8 && !USER_HAS_BULK_PERMISSIONS) {
      limitAlert()
      return false
    }
    // because we typically start out with one blank row
    // this removes it before the csv data gets inserted into the table
    removeBlankRows()

    csv.data.map(function(rowData){
      // downcase the keys
      var r = {}
      Object.keys(rowData).forEach(function(key) {
        r[key.toLowerCase()] = rowData[key]
      })
      return r
    }).forEach(function(rowData) {
      var newRow = newBlankRow()
      traverseRow(columns, newRow, function(rowInfo, cell) {
        updateCellData(cell, rowInfo, rowData[rowInfo.key])
      })
    })
  }

  // input: str (element id of <input type="file">)
  // attaches a callback to the provided element
  // which calls csvToTable with the contents of the file
  // after a file has been selected
  function readCSVFileListener(fileInputId) {
    if (!utility.browserCanOpenFiles()) { return }

    function handleFileSelect() {
      if (this.files.length > 0) {  // do nothing if no file is selected
        var reader = new FileReader()
        reader.onloadend = function() {  // triggered when file is finished being read
          if (reader.result) {
            csvToTable(reader.result)
          } else {
            console.error('Error reading the csv file or the file is empty')
          }
        }
        reader.readAsText(this.files[0])
      }
    }

    document.getElementById(fileInputId).addEventListener('change', handleFileSelect, false)
  }

  /* ENTITY MATCH */

  // input: str|element
  function scrollTo(selector) {
    $('html, body').animate({
      scrollTop: ($(selector).offset().top - 55)
    }, 200)
  }

  // input: <tr> | undefined
  function highlightRow(row) {
    $('#table tbody tr').removeClass('info')
    if (row) {
      $(row).addClass('info')
    }
  }

  // input: int
  // output: <div>
  function skipBtn() {
    var skip = $('<button>', {
      "type": 'button',
      "class": 'btn btn-default',
      "text": 'Skip / Create new entity',
      "click": function() {
        MATCHING_INDEX++
        entityMatch()
      }
    })
    return $('<div>').append(skip)
  }

  // input: int
  // output: <h2>
  function innerMatchBoxTitle() {
    return $('<h2>', {
      "text": 'Select a matching LittleSis Entity',
      "class": 'text-center'
    }).append(skipBtn())
  }

  // Compiled template for table row
  // see bulk_relationships.html.erb for template

  var entityMatchTableRowTemplate = '<td>{{ name }}</td><td>{{ blurb }}</td><td class="profile-link"><a href="{{ url }}" target="_blank">View profile</a></td>'

  // and appends results to the table
  // input: <tr>
  function searchAndDisplay(row) {
    var name = $(row).find('td:nth-child(1)').text()
    // search for matches
    searchRequest(name, function(results){

      if (results.length > 0) {
        // loop through results
        results.forEach(function(entity) {

          var tr = $('<tr>', {
            "click": function(event) {
              if (event.target.tagName === "A") {
                // DO NOTHING
                // this means the user has clicked on the 'view profile' link
                // and we don't want that to trigger a selection
              } else {
                entitySelect($(row).find('td:first-child'), entity)
                MATCHING_INDEX++
                entityMatch()
              }
            }
          }).append(Mustache.render(entityMatchTableRowTemplate, entity))

          // add row to table
          $('#match-results-table tbody').append(tr)
        })
      } else {
        var nothingFound = $('<h3>', {
          class: 'text-center',
          text: 'No matching entities found'
        })
        $('#match-results-table-container').html(nothingFound)
      }
    })
  }

  // input: <tr>
  function matchBox(row) {
    searchAndDisplay(row)

    var box = $('<div>', {
      css: {
        "width": $(row).width(),
        "height": '450px',
        "background": 'rgba(255, 255, 255, 0.9)',
        "position": 'absolute',
        "box-shadow": '5px 5px 5px rgba(0, 0, 0, 0.3)',
        "z-index": '100',
        "overflow": 'scroll',
        "top": $(row).offset().top + 52,
        "left": $(row).offset().left
      },
      class: 'entity-match-box'
    })
    .append(innerMatchBoxTitle())
    .append($('#entityMatchTable').html())

    $('body').append(box)
  }

  function clearMatchingTable() {
    $('#table tbody tr').removeClass('info')
    $('.entity-match-box').remove()
  }

  // Matches the name to LittleSis Entity for each row (if not yet matched)
  function entityMatch() {
    var row = $('#table > table > tbody > tr')[MATCHING_INDEX]
    clearMatchingTable()

    if (typeof row === 'undefined') {
      $('.entity-match-btn').trigger('click')
      return
    } else {
      highlightRow(row)
      scrollTo(row)
      matchBox(row)
    }
  }

  function recreateTableHeader() {
    $('#table thead tr').empty()
      createTableHeader()
  }


  /* toggle helpers */

  // <element> => String
  function toggleButtons(element) {
    $(element).find('.btn').toggleClass('active')
    $(element).find('.btn').toggleClass('btn-primary')
    // $(element).find('.btn').toggleClass('btn-default');
    return $(element).find('button.btn.active').text()
  }

  // shows or hides NOTES column
  function toggleNotes() {
    var notesColIndex = $('#table thead tr th')
      .toArray()
      .findIndex(function(th) { return th.innerText === 'Notes' })

    var notesColSelector = "#table tbody tr > td:nth-child(" + (notesColIndex +1) + ")"

    $(notesColSelector).each(function() {
      $(this).toggle()
    })
  }

  // Establishes listeners for:
  //   - click to add a new row
  //   - remove row
  //   - select a relationship category
  //   - upload data button click
  function domListeners() {
    $('#table').on('click', '.table-add', function() { newBlankRow() })

    // handler to remove row
    // by clicking 'X' in right-most column in table
    $('#table').on('click', '.table-remove', function() {
      var index = $(this).parents('tr').index()
      $(this).parents('tr').remove()

      // If we are currently matching names,
      // adjust the index of the queue
      if (MATCHING_MODE) {
        if (index < MATCHING_INDEX) {
          MATCHING_INDEX--
        }
        entityMatch()
      }
    })

    $('#relationship-cat-select').change(function(){
      createTable()
      $('#upload-btn').removeClass('hidden')
    })
    $('#upload-btn').click(function() {
      submit()
    })

    $('#notes-mode-toggle').click(function(){
      var status = toggleButtons(this)
      if (status == 'ON') {
        NOTES_MODE = true
      } else {
        NOTES_MODE = false
      }
      toggleNotes()
      recreateTableHeader()
    })

    $('#autocomplete-toggle').click(function() {
      $(this).find('.btn').toggleClass('active')
      $(this).find('.btn').toggleClass('btn-primary')
      var status = $(this).find('button.btn.active').text()
      AUTOCOMPLETE_MODE = status === 'ON'
    })
  }

  function init(hasBulkPermission) {
    USER_HAS_BULK_PERMISSIONS = Boolean(hasBulkPermission)
    domListeners()
  }

  return {
    relationshipDetails: relationshipDetails,
    relationshipDetailsAsObject: relationshipDetailsAsObject,
    createTable: createTable,
    tableToJson: tableToJson,
    search: searchRequest,
    newBlankRow: newBlankRow,
    validate: validate,
    cellValidation: cellValidation,
    invalidDisplay: invalidDisplay,
    removeBlankRows: removeBlankRows,
    afterRequest: afterRequest,
    toggleNotes: toggleNotes,
    init: init
  }
}
