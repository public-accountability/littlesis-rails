select
  concat(id, 'normal') as id,
  entity1_id,
  entity2_id,
  category_id,
  id as relationship_id,
  false as is_reverse,
  is_deleted
from relationship

union

select
  concat(id, 'reverse') as id,
  entity2_id as entity1_id,
  entity1_id as entity2_id,
  category_id,
  id as relationship_id,
  true as is_reverse,
  is_deleted
from relationship
