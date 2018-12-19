/*
We want to be able to create lists of entities that have been edited recently.

"Entity" is the core table and model that edited on LittleSis. Many actions only
change models other than an entity directly are still considered an edit to that entity.
For instance, if a user adds a tag to an entity, it doesn't change the Entity table but
instead adds a new row to `tagging`. We want that change and other to be represented 
as an "edited entity".

One additional complication: edits to relationships are considered to be an edit of two 
different entities at the same time. Those rows need to into split into two different "edits."

This function returns a JSON array contains objects with the following fields:

entity_id     ID of the entited entity
created_at    when the edit occured
user_id       ID of the user who edited the entity
version_id    Primary ID of the version table
item_type     The model that was edited. i.e. Person, Relationship, etc.
item_id       Id of the model that was edited.

The result set will contain duplicates. Futher processing of this data is handled by ruby.

*/
DELIMITER //

CREATE OR REPLACE FUNCTION recent_entity_edits(history_limit INTEGER, user_id VARCHAR(255))
RETURNS JSON DETERMINISTIC READS SQL DATA
BEGIN

  /*
     This the variable returned at the end of the function.
     The function builds an json array of objects
  */
  DECLARE json JSON;

  /*
     These variables are mutated during each loop of the query.
     (The underscores are to avoid conflicts with column names)
  */
  DECLARE _version_id BIGINT;
  DECLARE _item_type VARCHAR(255);
  DECLARE _item_id INTEGER;
  DECLARE _entity1_id INTEGER;
  DECLARE _entity2_id INTEGER;
  DECLARE _user_id INTEGER;
  DECLARE _created_at DATETIME;

  DECLARE done BOOL DEFAULT FALSE; -- var used by "continue handler"

  -- create cursor to query the versions table
  DECLARE versions_cursor CURSOR FOR
  	  		  SELECT id, item_type, item_id, entity1_id, entity2_id, CAST(whodunnit AS INTEGER), created_at
  			  FROM versions
  			  WHERE entity1_id IS NOT NULL AND
			  (CASE WHEN user_id is NOT NULL THEN whodunnit = user_id ELSE TRUE END)
  			  ORDER BY id desc
  			  limit history_limit;

  -- when cursor is finished set var "done". Used to exit the loop.
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Initalize json variable to empty array
  SET json = JSON_ARRAY();

  OPEN versions_cursor;

  read_loop: LOOP
     FETCH versions_cursor INTO _version_id, _item_type, _item_id, _entity1_id, _entity2_id, _user_id, _created_at;

     IF done THEN
      LEAVE read_loop;
     END IF;

     /*
       the "CAST as INT" is a fix until this bug is resolved: https://jira.mariadb.org/browse/MDEV-14438
      */
     SET json = JSON_ARRAY_APPEND(json, '$', JSON_OBJECT("entity_id", CAST(_entity1_id AS INT),
     				                         "version_id", CAST(_version_id AS INT),
     				     	                 "item_type", _item_type,
     					                 "item_id", CAST(_item_id AS INT),
     					                 "user_id", CAST(_user_id as INT),
     					                 "created_at", _created_at));

     -- If entity2_id has data (i.e. an edit to a relationship), we add
     -- a second object the array which is nearly the same as the first object
     -- except that the entity_id is not entity1_id

     IF _entity2_id IS NOT NULL THEN

       SET json = JSON_ARRAY_APPEND(json, '$', JSON_OBJECT("entity_id", CAST(_entity2_id AS INT),
     				                           "version_id", CAST(_version_id AS INT),
     				     	                   "item_type", _item_type,
     					                   "item_id", CAST(_item_id AS INT),
     					                   "user_id", CAST(_user_id AS INT),
     					                   "created_at", _created_at));
     END IF;


  END LOOP;
  CLOSE versions_cursor;

  RETURN json;

END

//

DELIMITER ;
