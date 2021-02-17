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
CREATE OR REPLACE FUNCTION recent_entity_edits(history_limit INTEGER, user_id TEXT) RETURNS JSON AS $$
DECLARE
  version_record RECORD;
  json_results json[];
BEGIN

        json_results := array[]::json[];

        FOR version_record IN
          SELECT id, item_type, item_id, entity1_id, entity2_id, whodunnit, created_at
  	  FROM versions
          WHERE entity1_id IS NOT NULL AND (CASE WHEN user_id is NOT NULL THEN whodunnit = user_id ELSE TRUE END)
          ORDER BY created_at desc
          LIMIT history_limit
        LOOP

          json_results := array_append(json_results,
                                       json_build_object('entity_id', version_record.entity1_id,
                                                         'version_id', version_record.id,
                                                         'item_type', version_record.item_type,
                                                         'item_id', version_record.item_id,
                                                         'user_id', version_record.whodunnit::integer,
                                                         'created_at', to_char(version_record.created_at, 'YYYY-MM-DD HH24:MI:SS')));

         IF version_record.entity2_id IS NOT NULL THEN
           json_results := array_append(json_results,
                                       json_build_object('entity_id', version_record.entity2_id,
                                                         'version_id', version_record.id,
                                                         'item_type', version_record.item_type,
                                                         'item_id', version_record.item_id,
                                                         'user_id', version_record.whodunnit::integer,
                                                         'created_at', to_char(version_record.created_at, 'YYYY-MM-DD HH24:MI:SS')));
         END IF;

        END LOOP;


        RETURN array_to_json(json_results);
END;

$$ LANGUAGE plpgsql STABLE;
