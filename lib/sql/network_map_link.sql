DELIMITER //

CREATE OR REPLACE FUNCTION network_map_link (id BIGINT, title VARCHAR(100))
RETURNS TEXT CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci' DETERMINISTIC
BEGIN
  DECLARE param varchar(250);
  SET param = LCASE(REPLACE(REPLACE(TRIM(title), ' ', '-'), '/', '_'));
  RETURN CONCAT('<a target="_blank" href="/maps/',
  	 	CAST(id as CHAR), '-', param,
		'">', TRIM(title), '</a>');
END

//

DELIMITER ;
