# frozen_string_literal: true

module Sitemap
  def self.run
    FileUtils.mkdir_p Rails.root.join("public/sitemap")
    FileUtils.rm_rf Dir.glob(Rails.root.join("public/sitemap/*").to_s)
    pages
    entities
    relationships
    lists
    maps
    tags
    gzip
    index
  end

  def self.gzip
    Rails.root.join("public/sitemap").children.each do |file|
      system "gzip --keep #{file}"
    end
  end

  def self.index
    File.open(Rails.root.join("public/sitemap/sitemap.xml"), 'w') do |ifile|
      ifile.puts '<?xml version="1.0" encoding="UTF-8"?>'
      ifile.puts '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
      Dir.glob(Rails.root.join("public/sitemap/*.txt.gz")).each do |f|
        ifile.puts "<sitemap>"
        ifile.puts "<loc>https://littlesis.org/sitemap/#{File.basename(f)}</loc>"
        ifile.puts "<lastmod>#{File.stat(f).mtime.iso8601}</lastmod>"
        ifile.puts "</sitemap>"
      end
      ifile.puts '</sitemapindex>'
    end
  end

  def self.pages
    File.open(Rails.root.join("public/sitemap/pages.txt"), 'w') do |f|
      f.puts "https://littlesis.org"
      %w[about join help api disclaimer contact donate oligrapher tags lists login bulk_data toolkit swamped].each do |path|
        f.puts "https://littlesis.org/#{path}"
      end
    end
  end

  def self.entities
    Entity.find_in_batches(batch_size: 5_000).with_index do |group, idx|
      File.open(Rails.root.join("public/sitemap/entities#{idx.to_s.rjust(2, '0')}.txt"), 'w') do |f|
        group.each do |entity|
          f.puts entity.url
          %w[interlocks giving datatable references].each do |path|
            f.puts "#{entity.url}/#{path}"
          end
        end
      end
    end
  end

  def self.relationships
    Relationship.find_in_batches(batch_size: 25_000).with_index do |group, idx|
      File.open(Rails.root.join("public/sitemap/relationships#{idx.to_s.rjust(2, '0')}.txt"), 'w') do |f|
        group.each do |relationship|
          f.puts relationship.url
        end
      end
    end
  end

  def self.lists
    File.open(Rails.root.join("public/sitemap/lists.txt"), 'w') do |f|
      List.public_scope.each do |list|
        unless list.list_entities.count.zero?
          f.puts list.url
        end
      end
    end
  end

  def self.maps
    File.open(Rails.root.join("public/sitemap/maps.txt"), 'w') do |f|
      NetworkMap.where(is_private: false).find_each do |map|
        f.puts map.url
      end
    end
  end

  def self.tags
    File.open(Rails.root.join("public/sitemap/tags.txt"), 'w') do |f|
      Tag.all.each do |tag|
        f.puts Rails.application.routes.url_helpers.tag_url(tag)
      end
    end
  end
end
