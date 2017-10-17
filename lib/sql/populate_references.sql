INSERT INTO references(document_id, referenceable_id, referenceable_type)
SELECT documents.id as document_id,
       legacy_references.object_id as referenceable_id,
       case legacy_references.object_model when 'LsList' then 'list' else legacy_references.object_model end as referenceable_type
FROM (
       SELECT SHA1(TRIM(source)) as url_hash,
       	      object_model,
	      object_id
       FROM reference
       GROUP BY url_hash, object_model, object_id
) as legacy_references
INNER JOIN documents on documents.url_hash = legacy_references.url_hash;


