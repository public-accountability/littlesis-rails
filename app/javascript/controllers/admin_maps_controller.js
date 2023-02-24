import { Controller } from "@hotwired/stimulus"
import datatable from "datatables.net"
import { post } from "../src/common/http.mjs"

const columns = [
  {
    data: "title",
    render: function (data, type, row, meta) {
      if (type === "display") {
        return `<a href="${row.url}" target="_blank">${data}</a>`
      } else {
        return data
      }
    },
  },
  {
    data: "username",
    render: function (data, type, row, meta) {
      if (type === "display") {
        return `<a href="/users/${data}" target="_blank">${data}</a>`
      } else {
        return data
      }
    },
  },
  {
    data: "created_at",
    searchable: false,
    render: (data, type) => (type === "display" ? data.slice(0, 10) : data),
  },
  {
    data: "is_featured",
    searchable: false,
    sortable: false,
    render: function (data, type, row, meta) {
      if (type === "display") {
        let iconClass = data ? "star" : "not-star"
        return `<button type="button" data-oligrapherid="${row.id}" data-action="click->admin-maps#feature" class="star-button"><span class="pe-none ${iconClass}"></span></button>`
      } else {
        return ""
      }
    },
  },
  {
    data: "id",
    searchable: false,
    sortable: false,
    render: function (data, type, row, meta) {
      if (type === "display") {
        let iconClass = "pe-none bi bi-trash"
        return `<button type="button" class="btn btn-light btn-sm" data-oligrapherid="${row.id}" data-action="click->admin-maps#soft_delete"><span class="${iconClass}"></span></button>`
      } else {
        return data
      }
    },
  },
]

export default class extends Controller {
  initialize() {
    $(this.element).DataTable({
      ajax: "/oligrapher/all.json",
      columns: columns,
      order: [[2, "desc"]],
    })
  }

  feature(event) {
    try {
      const id = event.target.dataset.oligrapherid
      const url = `/oligrapher/${id}/featured`
      post(url, {}).then(() => {
        const span = event.target.querySelector("span")
        span.classList.toggle("star")
        span.classList.toggle("not-star")
      })
    } catch (err) {
      console.error(err)
    }
  }

  soft_delete(event) {
    if (window.confirm("Are you sure?")) {
      try {
        const id = event.target.dataset.oligrapherid
        const url = `/oligrapher/${id}/admin_destroy`

        post(url, {}, { delete: true }).then(() => {
          $(this.element).DataTable().row($(event.target).parents("tr")).remove().draw()
        })
      } catch (err) {
        alert("Error: failed to delete this map")
        console.error(err)
      }
    }
  }
}
