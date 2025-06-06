# frozen_string_literal: true

class ListsGrid < BaseGrid
  scope do
    List
      .where("access < 3")
      .order(created_at: :desc)
  end

  column(:name, header: "List Name", html: true, order: false) do |list|
    link_to list.name, "#{list.url}"
  end

  column(:short_description, header: "Short Description", order: false) do |list|
    list.short_description
  end

  column(:creator_user_id, header: "Creator", html:true, order: false) do |list|
    creator = User.find(list.creator_user_id)
    link_to creator.username, "/user/#{creator.username}"
  end
end
