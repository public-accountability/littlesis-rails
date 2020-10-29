SELECT
  entity1_id,
  entity2_id,
  category_id,
  false AS is_reverse,
  id AS relationship_id
FROM relationship

UNION

SELECT
  entity2_id AS entity1_id,
  entity1_id AS entity2_id,
  category_id,
  true AS is_reverse,
  id AS relationship_id
FROM relationship
