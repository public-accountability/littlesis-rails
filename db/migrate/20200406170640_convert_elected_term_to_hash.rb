class ConvertElectedTermToHash < ActiveRecord::Migration[6.0]
  def up
    add_column :membership, :elected_term_hash, :text

    Membership.with_elected_term.find_each do |membership|
      membership.update_column :elected_term_hash, membership.elected_term.to_h.stringify_keys
    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
