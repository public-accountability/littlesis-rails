# frozen_string_literal: true

module RegistrationsHelper
  def registrations_form_group(group_class: 'row mb-2', column_class: 'col-sm-12 col-md-10 col-lg-8', &block)
    tag.div(class: group_class) do
      tag.div(class: column_class, &block)
    end
  end
end
