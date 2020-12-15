# frozen_string_literal: true

module BootstrapHelper
  def bootstrap_form_group_input(label, type: 'text', size: 2, input_name: nil, label_data: nil)
    domid = "littlesis-#{SecureRandom.hex(5)}"
    label_class = "col-sm-#{size} col-form-label"
    div_class = "col-sm-#{12 - size}"

    input_element = tag.input(type: type,
                              class: 'form-control',
                              id: domid,
                              name: input_name,
                              data: label_data)

    tag.div(class: 'form-group row') do
      tag.label(label, for: "\##{domid}", class: label_class) +
        tag.div(input_element, class: div_class)
    end
  end
end
