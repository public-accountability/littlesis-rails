class LsFormBuilder < ActionView::Helpers::FormBuilder
  
  def tri_boolean(method, options = {})
    @template.content_tag(:div) do
      @template.radio_button( @object_name, method, 'true', objectify_options(options) )  +
        @template.radio_button( @object_name, method, 'false', objectify_options(options) ) +
        @template.radio_button( @object_name, method, 'nil', objectify_options(options) )
    end
  end

end
