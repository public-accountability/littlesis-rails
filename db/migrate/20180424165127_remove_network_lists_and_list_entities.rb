class RemoveNetworkListsAndListEntities < ActiveRecord::Migration[5.1]
  def up
    list_ids = [78, 79, 96, 132, 133, 198]
    list_ids.each { |list_id| List.find_by(id: list_id)&.delete }

    list_ids.each do |list_id|
      ListEntity.unscoped.where(list_id: list_id).delete_all
    end
    
  end

  def down
    List.create!([
                   {name: "Buffalo", description: "Powerful individuals in Buffalo, NY, including business, political, and social leaders.", is_ranked: false, is_admin: true, is_featured: false, display_name: "buffalo", featured_list_id: nil,last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
                   {name: "United States", description: "People and organizations with significant influence on the policies of the United States.", is_ranked: false, is_admin: true, is_featured: false, display_name: "us", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
                   {name: "United Kingdom", description: "People and organizations with significant influence on the policies of the United Kingdom.", is_ranked: false, is_admin: true, is_featured: false, display_name: "uk", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
                   {name: "Baltimore", description: "Powerful individuals in Baltimore, MD, including business, political, and social leaders.", is_ranked: false, is_admin: true, is_featured: false, display_name: "baltimore", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
                   {name: "New York State", description: "Powerful individuals in New York State, including business, political, and social leaders.", is_ranked: false, is_admin: true, is_featured: false, display_name: "nys", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false},
                   {name: "Oakland", description: "Powerful individuals in Oakland, CA, including business, political, and social leaders.", is_ranked: false, is_admin: true, is_featured: false, display_name: "oakland", featured_list_id: nil, last_user_id: 1, is_deleted: false, custom_field_name: nil, delta: false}
                 ])
  end
end
