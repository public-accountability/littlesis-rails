CREATE INDEX IF NOT EXISTS individual_contributions_cmte_id_idx ON individual_contributions (CMTE_ID);
CREATE INDEX IF NOT EXISTS individual_contributions_transaction_tp_idx ON individual_contributions (TRANSACTION_TP);

-- CREATE UNIQUE INDEX IF NOT EXISTS committees_cmte_id_fec_year_idx ON committees (CMTE_ID, FEC_YEAR);
-- CREATE UNIQUE INDEX IF NOT EXISTS pac_summaries_cmte_id_fec_year_idx ON pac_summaries (CMTE_ID, FEC_YEAR);
