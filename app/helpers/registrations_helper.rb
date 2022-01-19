# frozen_string_literal: true

module RegistrationsHelper
  REGISTRATIONS_FORM_CLASSES = {
    :group => 'row',
    :column => 'col-sm-12 col-md-10 col-lg-8'
  }.freeze

  def registrations_form_group(group_class: REGISTRATIONS_FORM_CLASSES[:group], column_class: REGISTRATIONS_FORM_CLASSES[:column])
    content_tag(:div, class: group_class) do
      content_tag(:div, class: column_class) do
        yield
      end
    end
  end
end
