namespace :industries do
  desc "generate industries from os_categories"
  task generate: :environment do
    OsCategory.all.each do |c|
      Industry.find_or_create_by(industry_id: c.industry_id) do |i|
        i.name = c.industry_name
        i.sector_name = c.sector_name
      end
    end
  end
end