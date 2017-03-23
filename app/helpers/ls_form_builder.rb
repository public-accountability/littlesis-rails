class LsFormBuilder < ActionView::Helpers::FormBuilder
  # This is a custom radio button selection with three options: true, false, and nil
  # to use: f.tri_boolean(:column, options)
  def tri_boolean(method, options = {})
    check_if_column_exists_and_is_boolean(method)
    status = @object.send(method)
    radio_options = lambda { |checked| objectify_options(options.merge(checked: checked)) }

    @template.content_tag(:div, class: 'tri-boolean-container') do
      @template.radio_button(@object_name, method, 'true', radio_options.call(status == true)) +
        @template.radio_button(@object_name, method, 'false', radio_options.call(status == false)) +
        @template.radio_button(@object_name, method, 'nil', radio_options.call(status.nil?))
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

end
