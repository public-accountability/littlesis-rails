// helper functions for searchcing with select2

export const ENTITY_SEARCH_URL = "/search/entity"

export function entitySearchSuggestion(entity) {
  return $(
    `<div class="entity-search-suggestion">
      <div class="entity-search-suggestion-name">
       <span class="entity-search-suggestion-name-text font-weight-bold">
         ${entity.name}
       </span>
      </div>
      <div class="entity-search-suggestion-blurb">
        ${entity.blurb || ''}
      </div>
     </div>`)
}

export function processResults(data) {
  let results = data.map(entity => {
    entity.text = entity.name
    return entity
  })
  return { "results": results }
}
