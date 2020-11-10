DROP TABLE IF EXISTS donor_names;

CREATE VIRTUAL TABLE donor_names
USING fts5(name, content=donors, content_rowid=id);
