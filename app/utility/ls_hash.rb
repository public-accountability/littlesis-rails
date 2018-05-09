# frozen_string_literal: true

##
# LittleSis's very own hash!
#
class LsHash < ActiveSupport::HashWithIndifferentAccess
  def with_last_user(user_or_user_id)
    merge(last_user_id: User.derive_last_user_id_from(user_or_user_id))
  end

  def remove_nil_vals
    delete_if { |_k, v| v.nil? }
  end

  # converts all values that resopnd .blank?
  # to nil, except for false
  def nilify_blank_vals
    transform_values do |val|
      if val.blank? && val != false
        nil
      else
        val
      end
    end
  end
end
