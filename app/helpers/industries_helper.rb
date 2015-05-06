module IndustriesHelper
  def industry_link(industry)
    link_to(industry.name, industry_path(industry))
  end
end
