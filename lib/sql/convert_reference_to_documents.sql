-- This sets the limit of group concat to the maximum
-- The queries concat large columns of text together
-- The default is very small: 1024
-- see: https://dev.mysql.com/doc/refman/5.5/en/server-system-variables.html#sysvar_group_concat_max_len
SET group_concat_max_len = 18446744073709547520;


-- SUBSTRING_INDEX(GROUP_CONCAT ...) is a mysql hack
-- for the the aggregate function first().
-- This line SUBSTRING_INDEX(GROUP_CONCAT(name SEPARATOR '^'), '^', 1) as name
-- can be interpreted as "pick the first name"
-- ^ is used as the separator instead of a comma because it is not used in any reference name

-- Create a table of uniq reference, which will be 
-- be used to populate the documents table
CREATE TABLE uniq_references AS
SELECT TRIM(source) as url,
       SHA1(TRIM(source)) as url_hash,
       SUBSTRING_INDEX(GROUP_CONCAT(name SEPARATOR '^'), '^', 1) as name,
       max(publication_date) as publication_date,
       min(created_at) as created_at,
       max(updated_at) as updated_at,
       SUBSTRING_INDEX(GROUP_CONCAT(CAST(ref_type AS CHAR)), ',', 1) as ref_type
FROM reference
GROUP BY TRIM(source);

INSERT INTO documents (name, url, url_hash, publication_date, ref_type, created_at, updated_at)
SELECT name,
       url,
       url_hash,
       publication_date,
       CAST(ref_type AS UNSIGNED) as ref_type,
       COALESCE(created_at, current_timestamp),
       COALESCE(updated_at, current_timestamp)
FROM uniq_references
WHERE url IS NOT NULL AND URL <> '';

DROP TABLE uniq_references;

-- Symfony stores reference excerpts in their own table, but the new design
-- puts those excerpts on the document model itself

-- Gather unique excerpts per URLS and store them in a table
CREATE TABLE uniq_excerpts AS
SELECT TRIM(reference.source) as url,
	    SUBSTRING_INDEX(GROUP_CONCAT(reference_excerpt.body SEPARATOR '^'), '^', 1) as excerpt
FROM reference_excerpt
LEFT JOIN reference ON reference_excerpt.reference_id = reference.id
group by TRIM(reference.source);

-- update documents with those excerpts
UPDATE documents, uniq_excerpts
SET documents.excerpt = uniq_excerpts.excerpt
WHERE documents.url_hash = SHA1(uniq_excerpts.url) AND documents.excerpt is null;

DROP TABLE uniq_excerpts;
