-- IMPORTANT! IMPORTANT!
-- --------------------
-- This script DELETES columns and rows from the database.
-- It is only to be executed on local copies of the public data subset.

ALTER TABLE entity drop foreign key entity_ibfk_2;
ALTER TABLE entity DROP COLUMN last_user_id;
ALTER TABLE entity DROP COLUMN delta;

ALTER TABLE relationship drop foreign key relationship_ibfk_4;
ALTER TABLE relationship DROP COLUMN last_user_id;

ALTER TABLE reference drop foreign key reference_ibfk_1;
ALTER TABLE reference DROP COLUMN last_user_id;

ALTER TABLE reference_excerpt drop foreign key reference_excerpt_ibfk_2;
ALTER TABLE reference_excerpt DROP COLUMN last_user_id;

ALTER TABLE extension_record drop foreign key extension_record_ibfk_3;
ALTER TABLE extension_record DROP COLUMN last_user_id;

ALTER TABLE alias drop foreign key alias_ibfk_2;
ALTER TABLE alias DROP COLUMN last_user_id;

ALTER TABLE lobby_filing_relationship drop foreign key lobby_filing_relationship_ibfk_1;
ALTER TABLE link drop foreign key link_ibfk_1;
ALTER TABLE link drop foreign key link_ibfk_2;
ALTER TABLE link drop foreign key link_ibfk_3;

DELETE FROM entity WHERE is_deleted = 1;
DELETE FROM relationship WHERE is_deleted = 1;
