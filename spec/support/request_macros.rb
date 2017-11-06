module RequestExampleMacros
  def json
    JSON.parse(response.body)
  end
end
