#!/usr/bin/env ruby
require 'net/http'
require 'json'

url = "https://api.github.com/repos/public-accountability/oligrapher/releases"

# rails-root/public/oligrapher
outdir  = File.expand_path(File.join(File.dirname(__FILE__), "../../public/oligrapher"))

if ARGV[0] == '--list'
  JSON.parse(Net::HTTP.get(URI(url))).each do |release|
    puts release["tag_name"]
  end
  exit
end

if ARGV[0].nil?
  warn "tag missing"
  exit 1
end

release = JSON.parse(Net::HTTP.get(URI(url + '/tags/' + ARGV[0])))

if release['message'] === 'Not Found'
  puts "⚠️ #{ARGV[0]} not found"
  exit 1
end

release["assets"].each do |asset|
  local_path = File.join(outdir, asset["name"])

  if File.exist?(local_path) && File.size(local_path) == asset["size"]
    puts "✔️ #{asset['name']}"
  else
    puts "📥 #{asset['name']}"
    system "curl #{asset['browser_download_url']} -o #{local_path} -L --no-progress-meter", exception: true
    if File.exist?(local_path) && File.size(local_path) == asset["size"]
      puts "✔️ #{asset['name']}"
    else
      puts "❌ #{asset['name']}"
    end
  end
end
