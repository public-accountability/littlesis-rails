CREATE TABLE uniq_references AS
SELECT source as url,
       SHA1(source) as url_hash,
       SUBSTRING_INDEX(GROUP_CONCAT(name SEPARATOR '^'), '^', 1) as name,
       max(publication_date) as publication_date,
       min(created_at) as created_at,
       max(updated_at) as updated_at,
       SUBSTRING_INDEX(GROUP_CONCAT(CAST(ref_type AS CHAR)), ',', 1) as ref_type
FROM reference
GROUP BY source;

INSERT INTO documents (name, url, url_hash, publication_date, ref_type, created_at, updated_at)
SELECT name, url, url_hash, publication_date, CAST(ref_type AS UNSIGNED) as ref_type, created_at, updated_at
FROM uniq_references
WHERE url IS NOT NULL AND URL <> '';

DROP TABLE uniq_references;

CREATE TABLE uniq_excerpts AS
SELECT reference.source as url,
	    SUBSTRING_INDEX(GROUP_CONCAT(reference_excerpt.body SEPARATOR '^'), '^', 1) as excerpt
FROM reference_excerpt
LEFT JOIN reference ON reference_excerpt.reference_id = reference.id
group by reference.source;


DROP TABLE uniq_excerpts;
