class AddOsCommitteeRefToPoliticalFundraising < ActiveRecord::Migration
  def change
    add_reference :political_fundraising, :os_committee, index: true
  end
end
