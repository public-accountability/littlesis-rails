#!/usr/bin/env ruby

# adapted from: https://blog.skylight.io/hunting-for-leaks-in-ruby/

require 'set'
require 'json'

def memory_addresses(filepath)
  addrs = Set.new

  File.open(filepath, "r").each_line do |line|
    parsed = JSON.parse(line)
    addrs << parsed["address"] if parsed && parsed["address"]
  end

  addrs
end

# list of all items present in second but not the first
def diff_two(file1, file2)
  addrs = memory_addresses(file1)

  diff = []

  File.open(file2, "r").each_line do |line|
    parsed = JSON.parse(line)

    if parsed && parsed["address"] && !addrs.include?(parsed["address"])
      diff << parsed
    end
  end

  diff
end

# list of items present both second and third files but not the first
def diff_three(file1, file2, file3)
  first_addrs = memory_addresses(file1)
  third_addrs = memory_addresses(file3)

  diff = []

  File.open(file2, "r").each_line do |line|
    parsed = JSON.parse(line)

    if parsed && parsed["address"]
      if !first_addrs.include?(parsed["address"]) && third_addrs.include?(parsed["address"])
        diff << parsed
      end
    end
  end

  diff
end

def group_and_report(diff)
  # Group items
  diff.group_by do |x|
    [x["type"], x["file"], x["line"]]
  end.map do |x, y|
    # Collect memory size
    [x, y.count, y.inject(0){|sum,i| sum + (i['bytesize'] || 0) }, y.inject(0){|sum,i| sum + (i['memsize'] || 0) }]
  end.sort do |a,b|
    b[1] <=> a[1]
  end.each do |x, y,bytesize,memsize|
    # Output information about each potential leak
    puts "Leaked #{y} #{x[0]} objects of size #{bytesize}/#{memsize} at: #{x[1]}:#{x[2]}"
  end
end

exit 1 unless ARGV.length.between?(2, 3)

if ARGV.length == 2
  group_and_report diff_two(ARGV[0], ARGV[1])
elsif ARGV.length == 3
  group_and_report diff_three(ARGV[0], ARGV[1], ARGV[2])
else
  exit 1
end
