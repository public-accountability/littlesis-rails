module ApiHelper
  def attribute_line(attr, details)
    content_tag('li') do
      content_tag('mark', attr) + ': ' + details
    end
  end
end
