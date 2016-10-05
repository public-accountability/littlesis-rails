-- Insert NYS Disclosure data into MYSQL
-- +++++++++++++++++++++++++++++++++++++
-- Before running you must process the ALL_REPORTS.out file like such:
-- cat ALL_REPORTS.out | iconv -f ASCII -t UTF-8//IGNORE | sed 's/\"\"/\\N/g' > ALL_REPORTS.txt

LOAD DATA INFILE '/path/to/ALL_REPORTS.txt'
INTO TABLE ny_disclosures
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
(filer_id, report_id, transaction_code, e_year, transaction_id, @var1, @var2, contrib_code,contrib_type_code,corp_name,first_name,mid_init,last_name,address,city,state,zip,check_number,@var3,amount1,amount2,description,other_recpt_code,purpose_code1,purpose_code2,explanation,transfer_type,bank_loan_check_box,crerec_uid, @var4 )
SET created_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP,
    schedule_transaction_date = STR_TO_DATE(@var1, '%m/%d/%Y'),
    original_date = STR_TO_DATE(@var2, '%m/%d/%Y'),
    check_date = STR_TO_DATE(@var3, '%m/%d/%Y'),
    crerec_date = STR_TO_DATE(@var4, '%m/%d/%Y %T');
