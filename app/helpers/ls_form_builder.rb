class LsFormBuilder < ActionView::Helpers::FormBuilder
  # This is a custom radio button selection with three options: true, false, and nil
  # to use: f.tri_boolean(:column, options)
  def tri_boolean(method, options = {})
    check_if_column_exists_and_is_boolean(method)
    set_label_class(options)
    status = @object.send(method)
    radio_options = lambda { |checked| objectify_options(options.merge(checked: checked)) }

    @template.content_tag(:div, class: 'tri-boolean-container') do
      [
        @template.radio_button(@object_name, method, '1', radio_options.call(status == true)),
        @template.label(@object_name, "#{method}_true", 'Yes', class: @label_class),
        @template.radio_button(@object_name, method, '0', radio_options.call(status == false)),
        @template.label(@object_name, "#{method}_false", 'No', class: @label_class),
        @template.radio_button(@object_name, method, '', radio_options.call(status.nil?)),
        @template.label(@object_name, "#{method}_nil", 'Unknown', class: @label_class)
      ].reduce(:+)
    end
  end

  class ColumnIsNotBoolean < StandardError; end

  private

  # Raises error if the column is not boolean or is missing
  def check_if_column_exists_and_is_boolean(method)
    unless @object.has_attribute?(method) && @object.column_for_attribute(method).type == :boolean
      raise ColumnIsNotBoolean, "#{@object.class} does not have the column \"#{method}\" or it is not boolean"
    end
  end

  def set_label_class(options)
    @label_class = options[:label_class]
    @label_class = 'tri-boolean-label' unless @label_class
  end
end
