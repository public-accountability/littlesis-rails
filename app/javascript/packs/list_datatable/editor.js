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
    label: 'Interlock Ids:',
    name: 'interlock_ids'
  },
  {
    label: 'List Interlock Ids:',
    name: 'list_interlock_ids'
  }
];

export function Editor(element, editorConstructor, config){
  let editor = new editorConstructor({
    ajax: config['update_path'],
    table: element,
    fields: EditorFields,
  });

  if ( config['editable'] ){
    element.on('click', 'tbody td.rank', function() {
      editor.inline(this, { submitOnBlur: true });
    })
  }
}
