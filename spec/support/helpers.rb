def css(*args)
  expect(rendered).to have_css(*args)
end

def not_css(*args)
  expect(rendered).not_to have_css(*args)
end
