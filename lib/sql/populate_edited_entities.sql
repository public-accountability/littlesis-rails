--- This deletes and re-creates the table edited_entities

TRUNCATE edited_entities;

INSERT INTO edited_entities (user_id, version_id, entity_id, created_at)
(SELECT whodunnit::integer, id, entity1_id, created_at FROM versions WHERE entity1_id IS NOT NULL);

INSERT INTO edited_entities (user_id, version_id, entity_id, created_at)
(SELECT whodunnit::integer, id, entity2_id, created_at FROM versions WHERE entity2_id IS NOT NULL AND entity2_id != entity1_id);
