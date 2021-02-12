CREATE OR REPLACE FUNCTION network_map_link(id bigint, title text) RETURNS TEXT AS $$
  SELECT CONCAT('<a target="_blank" href="/maps/',
                CAST(id as text),
                '-',
                LOWER(REPLACE(REPLACE(TRIM(title), ' ', '-'), '/', '_')),
                '">',
                TRIM(title),
                '</a>');
$$ LANGUAGE SQL IMMUTABLE;
