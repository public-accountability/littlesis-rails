import { Controller } from "@hotwired/stimulus"
import { isEmpty } from 'lodash-es'
import { validURL } from '../src/common/utility.mjs'
import Http from '../src/common/http.mjs'
import NewReferenceForm from '../src/components/new_reference_form'
import ExistingReferenceWidget from '../src/components/existing_reference_selector'

const CATEGORIES_TEXT = [
      "",
      "Position",
      "Education",
      "Membership",
      "Family",
      "Donation/Grant",
      "Service/Transaction",
      "Lobbying",
      "Social",
      "Professional",
      "Ownership",
      "Hierarchy",
      "Generic"
]

const parentOrgSpan = '<span class="badge rounded-pill bg-light text-dark me-1">Parent Org</span>'

const resultsDataTableColumns = [
  {
    data: null,
    defaultContent: '<button data-action="click->relationship-creator#selectEntityEvent" type="button" class="btn btn-success btn-sm">select</button>'
  },
  {
    title: 'Name',
    render: (data, type, row) => `<a href="${row.url}" target="_blank">${row.name}${row.is_parent ? parentOrgSpan : ''}</a>`
  },
  {
    data: 'blurb',
    title: 'Summary'
  }
]

// str, str, boolean -> [int] | Throw Exception
function categories(entity1Type, entity2Type, isSchool = false) {
  let personToPerson = [1,4,5,6,8,9,12]
  let personToOrg = [1,2,3,5,6,10,12]
  let orgToPerson = [1,3,5,6,10,12]
  let orgToOrg = [3,5,6,10,11,12]

  if (entity1Type === 'Person' && entity2Type === 'Person') {
    return personToPerson
  } else if (entity1Type === 'Person' && entity2Type === 'Org') {
    return personToOrg;
  } else if (entity1Type === 'Org' && entity2Type === 'Person') {
    // if entity is a school, provide the option to, create a student relationship
    if (isSchool) {
      orgToPerson.splice(1, 0, 2)
    }

    return orgToPerson

  } else if (entity1Type === 'Org' && entity2Type === 'Org') {
    return orgToOrg
  } else {
    throw "Missing or incorrect primary extension type"
  }
}

// str, str, boolean -> HTML ELEMENT
function categorySelector(entity1Type, entity2Type, isSchool) {
  let buttonGroup = $('<div>', { class: 'btn-group-vertical', 'role': 'group', 'aria-label': 'relationship categories'});

  categories(entity1Type, entity2Type, isSchool).forEach(function(categoryId) {
    buttonGroup.append(
      $('<button>', {
	'type': 'button',
	'class': 'category-select-button btn btn-light border',
	'text': CATEGORIES_TEXT[categoryId],
	'data-categoryid': categoryId,
        'data-action': 'click->relationship-creator#onCategorySelect'
      })
      )
  })
  return buttonGroup;
}

function similarRelationshipsContent(relationships, category_id) {
  let text = "There already exists " +
      relationships.length + " " +
      CATEGORIES_TEXT[category_id] + " relationship"
      + (relationships.length > 1 ? 's. ' : '. ')

  let link = `<span><a href="/relationships/${relationships[0].id}" target="_blank">Click here</a> to eaxmine ${relationships.length > 1 ? 'one' : 'it'}</span>`

  return `<span>${text}${link}</span>`
}

function alertDiv(title, message) {
  return $('<div>', { class: 'alert alert-danger', role: 'alert' })
    .append($('<strong>', { text: title }))
    .append($('<span>', { text: message }))
}

function afterTurbo(event) {
  if (event.target.id === "new-entity-form") {
    if (event.target.querySelector('#new-entity-result-data')) {
      this.selectEntity(
        JSON.parse(event.target.querySelector('#new-entity-result-data').text)
      )
    } else if (event.target.querySelector('input[name="entity[name]"]')) {
      event.target.querySelector('input[name="entity[name]"]').value = this.searchTarget.value
    }
  }
}

export default class extends Controller {
  static targets = [ "search", "searchContainer", "results", "nothingFound", "newEntityForm", "creatingInfo", "form", "similarRelationships"]

  static values = {
    entity1Id: Number,
    entity1Name: String,
    entity1Url: String,
    entity1Type: String,
    entity1School: Boolean
  }

  initialize() {
    this.entity1_id = this.entity1IdValue
    this.entity1_type = this.entity1TypeValue
    this.entity2_id = null
    this.entity2_type = null
    this.newReferenceForm = null
    this.existingReferences = null
    this.category_id = null
    document.documentElement.addEventListener('turbo:frame-load', afterTurbo.bind(this))
  }

  search() {
    const query = this.searchTarget.value

    Http.get("/search/entity", { q: query, include_parent: true } )
      .then(data => {
        if (data.length > 0) {
           this.showSearchResults(data)
        } else {
          this.nothingFoundTarget.style.display = ''
          $(this.resultsTarget).html('')
        }
      })
  }

  showSearchResults(data) {
    this.nothingFoundTarget.style.display = 'none'
    this.newEntityFormTarget.style.display = 'none'
    $(this.resultsTarget).html('<table class="table compact hover" id="add-relationship-search-results-table"></table>')
    $(this.resultsTarget).find('table').DataTable({
      data: data,
      columns: resultsDataTableColumns,
      ordering: false,
      searching: false,
      lengthChange: false,
      info: false
    })
  }

  onCategorySelect(event) {
    $(event.target).addClass("active").siblings().removeClass("active")
    this.similarRelationshipsTarget.style.display = 'none'

    this.category_id = Number(event.target.dataset.categoryid)

    let params  = { entity1_id: this.entity1_id, entity2_id: this.entity2_id, category_id: this.category_id }
    Http.get('/relationships/find_similar', params)
      .then( relationships => {
        if (relationships.length > 0) {
          $(this.similarRelationshipsTarget).show()
          $("#similarRelationshipsDetails").html(similarRelationshipsContent(relationships, this.category_id))

        }
      })
      .catch(() => console.error('request to /relationships/find_similar failed'))
  }

  selectEntityEvent(event) {
    const entityData = $(this.resultsTarget).find('table').DataTable().row($(event.target).parents('tr')).data()
    this.selectEntity(entityData)
  }

  selectEntity(data) {
    this.nothingFoundTarget.style.display = 'none'
    this.newEntityFormTarget.style.display = 'none'
    this.entity2_id = data.id
    this.entity2_type = data.primary_ext

    const entity1Link = `<a href="${this.entity1UrlValue}" target="_blank">${this.entity1NameValue}</a>`
    const entity2Link = `<a href="${data.url}" target="_blank">${data.name}</a>`
    $(this.creatingInfoTarget).html(`<h3 class="text-center">Creating a new relationship between <br />${entity1Link}<br /> <em>and</em> <br />${entity2Link}</h3>`)

    this.searchContainerTarget.style.display = 'none'
    this.resultsTarget.style.display = 'none'
    this.formTarget.style.display = ''

    $('#category-selection').html(categorySelector(this.entity1TypeValue, data.primary_ext, this.entity1SchoolValue))

    this.newReferenceForm = new NewReferenceForm('#new-reference-form')
    this.existingReferences = new ExistingReferenceWidget([this.entity1_id, this.entity2_id])
  }

  toggleReference(event) {
    $(event.target).parent().find('.btn').toggleClass('active').toggleClass('btn-secondary').toggleClass('btn-outline-secondary')
    $('#existing-reference-container').toggle()
    $('#new-reference-container').toggle()
  }

  newEntity() {
    // shows element which triggers turbo-frame to load
    if (!this.newEntityFormTarget.offsetParent) {
      this.newEntityFormTarget.style.display = ''
    }
  }

  submit() {
    $('#errors-container').empty()
    const sd = this.submissionData()
    const errors = this.catchErrors(sd)

    if (isEmpty(errors)) {
      console.log('creating a new relationship:', sd)
      Http.post('/relationships', sd)
        .then(data => {
          window.location.replace("/relationships/" + data.relationship_id + "/edit?new_ref=true")
        })
        .catch(err => {
          console.error(err)
          this.displayErrors({ server: true })
        })
    } else {
      console.log('cannot create relationship:', errors)
      this.displayErrors(errors)
    }
  }

  submissionData() {
    let entity1_id = this.entity1_id
    let entity2_id = this.entity2_id
    // categories() defines the acceptable valid relationship options for combination of entity types.
    // As a convenience we allow some relationships to be selected in reverse, where the intended direction of the relationship is unambiguous.
    // This reverses the entity ids in those situations
    // Org-->People relationships are reversed for these categories: Position (1), Education (2), Membership (3), Ownership(10)
    if ([1,2,3,10].includes(this.category_id) && this.entity1_type  === 'Org' && this.entity2_type === 'Person') {
      let tmp = entity1_id
      entity1_id = entity2_id
      entity2_id = tmp
    }

    return {
      relationship: {
        entity1_id: entity1_id,
	entity2_id: entity2_id,
	category_id: this.category_id
      },
      reference: this.referenceData()
    }
  }

  referenceData() {
    if ($('#toggle-reference-form').find('.btn.active').attr('name') === 'create-reference') {
      return this.newReferenceForm.value()
    }

    if (this.existingReferences.selection) {
      return { "document_id": this.existingReferences.selection }
    }

    return { "document_id": null }
  }

  catchErrors(formData) {
    let errors = {}

    if (!formData.relationship.category_id) {
      errors.category_id = true
    }

    if (typeof formData.reference.document_id === 'undefined') {

      if (!formData.reference.name) {
        errors.reference_name = true
      }

      if (!formData.reference.url) {
        errors.url = true
      } else if (!validURL(formData.reference.url)) {
        errors.url = 'INVALID'
      }

    } else if (formData.reference.document_id === null) {
      errors.no_selection = true
    }

    return errors
  }

  displayErrors(errors) {
    let alerts = []

    if (errors.base) {
      alerts.push(alertDiv(errors.base))
    }

    if (errors.reference_name) {
      alerts.push(alertDiv('Missing information ', "Don't forget to add a reference name"))
    }

    if (errors.no_selection) {
      alerts.push(alertDiv('Missing information ', "Don't forget to select an existing reference"))
    }

    if (errors.url) {
      if (errors.url === 'INVALID') {
	alerts.push(alertDiv('Invalid data: ', "The reference url is invalid"))
      } else {
	alerts.push(alertDiv('Missing Url: ', "The reference url is missing"))
      }
    }

    if (errors.category_id) {
      alerts.push(alertDiv('Missing information ', "Don't forget to select a relationship category"))
    }

    if (errors.entity1_id || errors.entity2_id || errors.server) {
      alerts.push(alert('Something went wrong :( ', "Sorry about that! Please contact admin@littlesis.org"))
    }

    $('#errors-container').html(alerts)
    setTimeout( () => $('div.alert').fadeOut(2000), 3000)
  }
}
