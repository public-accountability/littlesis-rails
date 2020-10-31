# frozen_string_literal: true

module FEC
  module Types
    class Report < Base
      self.map = {
        '12C' => :pre_convention,
        '12G' => :pre_general,
        '12P' => :pre_primary,
        '12R' => :pre_runoff,
        '12S' => :pre_special,
        '30D' => :post_general,
        '30P' => :post_primary,
        '30R' => :post_runoff,
        '30S' => :post_special,
        '60D' => :post_convention,
        'ADJ' => :comprehensive_adjustment,
        'CA'  => :comprehensive_amendment,
        'M2'  => :february,
        'M3'  => :march,
        'M4'  => :april,
        'M5'  => :may,
        'M6'  => :june,
        'M7'  => :july,
        'M8'  => :august,
        'M9'  => :september,
        'M10' => :october,
        'M11' => :november,
        'M12' => :december,
        'MY' => :midyear,
        'Q1' => :april_quarterly,
        'Q2' => :july_quarterly,
        'Q3' => :october_quarterly,
        'TER' => :termination,
        'YE' => :year_end,
        '90S' => :post_inaugural_supplement,
        '48H' => :"48_hour",
        '24H' => :"24_hour"
      }
    end
  end
end
