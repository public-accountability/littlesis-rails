class AddDefaultListToTopics < ActiveRecord::Migration
  def change
    add_reference :topics, :default_list, index: true
  end
end
