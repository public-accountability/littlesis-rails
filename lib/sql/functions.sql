CREATE OR REPLACE FUNCTION round_five_minutes(timestamp without time zone)
RETURNS timestamp without time zone AS $$
  SELECT date_trunc('hour', $1) + interval '5 min' * round(date_part('minute', $1) / 5.0)
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION round_ten_minutes(timestamp without time zone)
RETURNS timestamp without time zone AS $$
  SELECT date_trunc('hour', $1) + interval '10 min' * round(date_part('minute', $1) / 10.0)
$$ LANGUAGE SQL IMMUTABLE;


CREATE OR REPLACE FUNCTION network_map_link(id bigint, title text) RETURNS TEXT AS $$
  SELECT CONCAT('<a target="_blank" href="/maps/',
                CAST(id as text),
                '-',
                LOWER(REPLACE(REPLACE(TRIM(title), ' ', '-'), '/', '_')),
                '">',
                TRIM(title),
                '</a>');
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION is_numeric(t text)
RETURNS boolean AS $$
   SELECT t ~ '^\d+$'
$$ LANGUAGE SQL IMMUTABLE;


CREATE OR REPLACE FUNCTION get_network_map_search_tsvector(network_map_id bigint) RETURNS tsvector AS $$
        SELECT setweight(to_tsvector(coalesce(network_maps.title,'')), 'A')  ||
                      setweight(to_tsvector(coalesce(network_maps.description,'')), 'B') ||
                      setweight(to_tsvector(coalesce(array_to_string(annotations.content, ' '), '')), 'C') ||
                      setweight(to_tsvector(coalesce(array_to_string(entities.names, ' '), '')), 'C')
        FROM network_maps,
             LATERAL (
               SELECT array_agg(entities.name) as names
               -- array_agg(entities.blurb) as blurbs
               FROM (
                      SELECT json_object_keys(graph_data::json -> 'nodes') as keys
                      FROM network_maps as sub
                      WHERE sub.id = network_maps.id
               ) AS nodes
               INNER JOIN entities on entities.id = keys::bigint
               WHERE nodes.keys ~ '^\d+$'
             ) as entities,
             LATERAL (
               SELECT array_agg(content.content) as content
               FROM  (
                       SELECT regexp_replace((json_array_elements(annotations_data::json)->> 'text') || ' ' || (json_array_elements(annotations_data::json)->> 'header'), E'<[^>]+>', '', 'gi') AS content
                       FROM network_maps as sub
                       WHERE sub.id = network_maps.id
                     ) as content
             ) as annotations
        WHERE network_maps.id = network_map_id
$$ LANGUAGE SQL;
