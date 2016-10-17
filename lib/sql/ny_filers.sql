-- Insert NYS Filer / COMMCAND data into MYSQL
-- +++++++++++++++++++++++++++++++++++++
-- Before running you must process the COMMCAND.txt file like such:
-- cat COMMCAND.txt | iconv -f ASCII -t UTF-8//IGNORE | sed 's/\"\"/\\N/g' > COMMCAND_1.txt

LOAD DATA INFILE '/path/to/COMMCAND_1.txt'
INTO TABLE ny_filers
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
(filer_id, name, filer_type, status, committee_type, office, district, treas_first_name, treas_last_name, address, city, state, zip)
SET created_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP;
