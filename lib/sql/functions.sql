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
