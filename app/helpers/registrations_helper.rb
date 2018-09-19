# frozen_string_literal: true

module RegistrationsHelper
  REGISTRATIONS_FORM_CLASSES = {
    :group => 'form-group row',
    :column => 'col-6'
  }.freeze

  def registrations_form_group(group_class: REGISTRATIONS_FORM_CLASSES[:group], column_class: REGISTRATIONS_FORM_CLASSES[:column])
    content_tag(:div, class: group_class) do
      content_tag(:div, class: column_class) do
        yield
      end
    end
  end
end
