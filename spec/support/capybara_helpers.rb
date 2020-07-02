module CapybaraHelpers
  # Capybara doesn't have its own simple way of handling Rails datetime selects
  def select_datetime(label_text, datetime)
    label = page.find('label', text: label_text)
    id = label['for']
    select datetime.year, from: "#{id}_1i"
    select datetime.strftime('%B'), from: "#{id}_2i"
    select datetime.day, from: "#{id}_3i"
    select datetime.strftime('%H'), from: "#{id}_4i"
    select datetime.strftime('%M'), from: "#{id}_5i"
  end
end
