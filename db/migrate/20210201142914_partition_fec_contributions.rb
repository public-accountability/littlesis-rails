class PartitionFECContributions < ActiveRecord::Migration[6.1]
  def change
    execute <<SQL
ALTER TABLE external_data_fec_contributions
PARTITION BY LIST (fec_year)
(
        PARTITION fec_year_2022 VALUES IN (2022),
        PARTITION fec_year_2020 VALUES IN (2020),
        PARTITION fec_year_2018 VALUES IN (2018),
        PARTITION fec_year_2016 VALUES IN (2016),
        PARTITION fec_year_2014 VALUES IN (2014),
        PARTITION fec_year_2012 VALUES IN (2012),
        PARTITION fec_year_2010 VALUES IN (2010),
        PARTITION fec_year_default DEFAULT
)
SQL
  end
end
