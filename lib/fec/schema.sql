CREATE TABLE IF NOT EXISTS candidates_summaries (
  CAND_ID TEXT NOT NULL,
  CAND_NAME TEXT,
  CAND_ICI CHAR(1),
  PTY_CD CHAR(1),
  CAND_PTY_AFFILIATION TEXT,
  TTL_RECEIPTS DECIMAL(14,2),
  TRANS_FROM_AUTH DECIMAL(14,2),
  TTL_DISB DECIMAL(14,2),
  TRANS_TO_AUTH DECIMAL(14,2),
  COH_BOP DECIMAL(14,2),
  COH_COP DECIMAL(14,2),
  CAND_CONTRIB DECIMAL(14,2),
  CAND_LOANS DECIMAL(14,2),
  OTHER_LOANS DECIMAL(14,2),
  CAND_LOAN_REPAY DECIMAL(14,2),
  OTHER_LOAN_REPAY DECIMAL(14,2),
  DEBTS_OWED_BY DECIMAL(14,2),
  TTL_INDIV_CONTRIB DECIMAL(14,2),
  CAND_OFFICE_ST CHAR(2),
  CAND_OFFICE_DISTRICT TEXT,
  SPEC_ELECTION TEXT,
  PRIM_ELECTION TEXT,
  RUN_ELECTION TEXT,
  GEN_ELECTION TEXT,
  GEN_ELECTION_PRECENT DECIMAL,
  OTHER_POL_CMTE_CONTRIB DECIMAL(14,2),
  POL_PTY_CONTRIB DECIMAL(14,2),
  CVG_END_DT TEXT,
  INDIV_REFUNDS DECIMAL(14,2),
  CMTE_REFUNDS DECIMAL(14,2),
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS candidates (
  CAND_ID TEXT NOT NULL,
  CAND_NAME TEXT,
  CAND_PTY_AFFILIATION TEXT,
  CAND_ELECTION_YR INTEGER,
  CAND_OFFICE_ST CHAR(2),
  CAND_OFFICE CHAR(1),
  CAND_OFFICE_DISTRICT CHAR(2),
  CAND_ICI CHAR(1),
  CAND_STATUS CHAR(1),
  CAND_PCC TEXT,
  CAND_ST1 TEXT,
  CAND_ST2 TEXT,
  CAND_CITY TEXT,
  CAND_ST CHAR(2),
  CAND_ZIP TEXT,
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS candidate_committee_linkages (
  CAND_ID TEXT NOT NULL,
  CAND_ELECTION_YR INTEGER NOT NULL,
  FEC_ELECTION_YR INTEGER NOT NULL,
  CMTE_ID TEXT,
  CMTE_TP TEXT,
  CMTE_DSGN TEXT,
  LINKAGE_ID INTEGER PRIMARY KEY,
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS congress_current_campaigns (
  CAND_ID TEXT NOT NULL,
  CAND_NAME TEXT,
  CAND_ICI CHAR(1),
  PTY_CD CHAR(1),
  CAND_PTY_AFFILIATION TEXT,
  TTL_RECEIPTS DECIMAL(14,2),
  TRANS_FROM_AUTH DECIMAL(14,2),
  TTL_DISB DECIMAL(14,2),
  TRANS_TO_AUTH DECIMAL(14,2),
  COH_BOP DECIMAL(14,2),
  COH_COP DECIMAL(14,2),
  CAND_CONTRIB DECIMAL(14,2),
  CAND_LOANS DECIMAL(14,2),
  OTHER_LOANS DECIMAL(14,2),
  CAND_LOAN_REPAY DECIMAL(14,2),
  OTHER_LOAN_REPAY DECIMAL(14,2),
  DEBTS_OWED_BY DECIMAL(14,2),
  TTL_INDIV_CONTRIB DECIMAL(14,2),
  CAND_OFFICE_ST CHAR(2),
  CAND_OFFICE_DISTRICT TEXT,
  SPEC_ELECTION TEXT,
  PRIM_ELECTION TEXT,
  RUN_ELECTION TEXT,
  GEN_ELECTION TEXT,
  GEN_ELECTION_PRECENT DECIMAL,
  OTHER_POL_CMTE_CONTRIB DECIMAL(14,2),
  POL_PTY_CONTRIB DECIMAL(14,2),
  CVG_END_DT TEXT,
  INDIV_REFUNDS DECIMAL(14,2),
  CMTE_REFUNDS DECIMAL(14,2),
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS committees (
  CMTE_ID TEXT NOT NULL,
  CMTE_NM TEXT,
  TRES_NM TEXT,
  CMTE_ST1 TEXT,
  CMTE_ST2 TEXT,
  CMTE_CITY TEXT,
  CMTE_ST CHAR(2),
  CMTE_ZIP TEXT,
  CMTE_DSGN CHAR(1),
  CMTE_TP CHAR(1),
  CMTE_PTY_AFFILIATION TEXT,
  CMTE_FILING_FREQ CHAR(1),
  ORG_TP CHAR(1),
  CONNECTED_ORG_NM TEXT,
  CAND_ID TEXT,
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS pac_summaries (
  CMTE_ID TEXT NOT NULL,
  CMTE_NM TEXT,
  CMTE_TP CHAR(1),
  CMTE_DSGN CHAR(1),
  CMTE_FILING_FREQ CHAR(1),
  TTL_RECEIPTS NUMBER(14,2),
  TRANS_FROM_AFF NUMBER(14,2),
  INDV_CONTRIB NUMBER(14,2),
  OTHER_POL_CMTE_CONTRIB NUMBER(14,2),
  CAND_CONTRIB NUMBER(14,2),
  CAND_LOANS NUMBER(14,2),
  TTL_LOANS_RECEIVED NUMBER(14,2),
  TTL_DISB NUMBER(14,2),
  TRANF_TO_AFF NUMBER(14,2),
  INDV_REFUNDS NUMBER(14,2),
  OTHER_POL_CMTE_REFUNDS NUMBER(14,2),
  CAND_LOAN_REPAY NUMBER(14,2),
  LOAN_REPAY NUMBER(14,2),
  COH_BOP DECIMAL(14,2),
  COH_COP DECIMAL(14,2),
  DEBTS_OWED_BY DECIMAL(14,2),
  NONFED_TRANS_RECEIVED DECIMAL(14,2),
  CONTRIB_TO_OTHER_CMTE DECIMAL(14,2),
  IND_EXP DECIMAL(14,2),
  PTY_COORD_EXP DECIMAL(14,2),
  NONFED_SHARE_EXP DECIMAL(14,2),
  CVG_END_DT TEXT,
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS individual_contributions (
  CMTE_ID TEXT NOT NULL,
  AMNDT_IND TEXT,
  RPT_TP TEXT,
  TRANSACTION_PGI TEXT,
  IMAGE_NUM TEXT,
  TRANSACTION_TP TEXT,
  ENTITY_TP TEXT,
  NAME TEXT,
  CITY TEXT,
  STATE TEXT,
  ZIP_CODE TEXT,
  EMPLOYER TEXT,
  OCCUPATION TEXT,
  TRANSACTION_DT TEXT,
  TRANSACTION_AMT NUMBER,
  OTHER_ID TEXT,
  TRAN_ID TEXT,
  FILE_NUM INTEGER,
  MEMO_CD TEXT,
  MEMO_TEXT TEXT,
  SUB_ID INTEGER PRIMARY KEY,
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS committee_contributions (
  CMTE_ID TEXT NOT NULL,
  AMNDT_IND TEXT,
  RPT_TP TEXT,
  TRANSACTION_PGI TEXT,
  IMAGE_NUM TEXT,
  TRANSACTION_TP TEXT,
  ENTITY_TP TEXT,
  NAME TEXT,
  CITY TEXT,
  STATE TEXT,
  ZIP_CODE TEXT,
  EMPLOYER TEXT,
  OCCUPATION TEXT,
  TRANSACTION_DT TEXT,
  TRANSACTION_AMT NUMBER,
  OTHER_ID TEXT,
  CAND_ID TEXT,
  TRAN_ID TEXT,
  FILE_NUM TEXT,
  MEMO_CD TEXT,
  MEMO_TEXT TEXT,
  SUB_ID INTEGER PRIMARY KEY,
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
  CMTE_ID TEXT NOT NULL,
  AMNDT_IND TEXT,
  RPT_TP TEXT,
  TRANSACTION_PGI TEXT,
  IMAGE_NUM TEXT,
  TRANSACTION_TP TEXT,
  ENTITY_TP TEXT,
  NAME TEXT,
  CITY TEXT,
  STATE TEXT,
  ZIP_CODE TEXT,
  EMPLOYER TEXT,
  OCCUPATION TEXT,
  TRANSACTION_DT TEXT,
  TRANSACTION_AMT NUMBER,
  OTHER_ID TEXT,
  TRAN_ID TEXT,
  FILE_NUM INTEGER,
  MEMO_CD TEXT,
  MEMO_TEXT TEXT,
  SUB_ID INTEGER PRIMARY KEY,
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS operating_expenditures (
  CMTE_ID TEXT NOT NULL,
  AMNDT_IND TEXT,
  RPT_YR INT,
  RPT_TP TEXT,
  IMAGE_NUM TEXT,
  LINE_NUM TEXT,
  FORM_TP_CD TEXT,
  SCHED_TP_CD TEXT,
  NAME TEXT,
  CITY TEXT,
  STATE TEXT,
  ZIP_CODE TEXT,
  TRANSACTION_DT TEXT,
  TRANSACTION_AMT NUMBER,
  TRANSACTION_PGI TEXT,
  PURPOSE TEXT,
  CATEGORY TEXT,
  CATEGORY_DESC TEXT,
  MEMO_CD TEXT,
  MEMO_TEXT TEXT,
  ENTITY_TP TEXT,
  SUB_ID INTEGER PRIMARY KEY,
  FILE_NUM INTEGER,
  TRAN_ID TEXT,
  BACK_REF_TRAN_ID TEXT,
  FEC_YEAR INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS donors (
  id INTEGER PRIMARY KEY,
  name TEXT,
  city TEXT,
  state TEXT,
  zip_code TEXT,
  employer TEXT,
  occupation TEXT
);

CREATE TABLE IF NOT EXISTS donor_individual_contributions (
   donor_id INTEGER NOT NULL,
   individual_contribution_sub_id INTEGER NOT NULL
);

-- CREATE TABLE IF NOT EXISTS organization_operating_expenditures (
--    organization_id INTEGER NOT NULL,
--    operating_expenditures_sub_id INTEGER NOT NULL UNIQUE
-- );

-- CREATE TABLE IF NOT EXISTS committee_connected_organizations (
--    committee_rowid INTEGER NOT NULL UNIQUE,
--    organization_id INTEGER NOT NULL
-- );

-- CREATE TABLE IF NOT EXISTS addresses (
--   id INTEGER PRIMARY KEY,
--   street TEXT,
--   city TEXT,
--   state TEXT,
--   zip_code TEXT
-- );

-- CREATE TABLE IF NOT EXISTS organizations (
--    id INTEGER PRIMARY KEY,
--    name TEXT NOT NULL UNIQUE
-- );

-- CREATE TABLE IF NOT EXISTS donor_employers (
--    donor_id INTEGER NOT NULL,
--    organization_id INTEGER NOT NULL
-- );
