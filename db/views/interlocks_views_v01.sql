SELECT
  links_view.entity1_id AS entity_id,
  links_view.entity2_id AS related_id,
  interlocks.entity1_id AS interlocked_entity_id
FROM links_view
  LEFT JOIN links_view interlocks
  ON interlocks.entity2_id = links_view.entity2_id
