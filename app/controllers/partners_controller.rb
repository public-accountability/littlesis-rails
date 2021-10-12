# frozen_string_literal: true

require 'csv'

class PartnersController < ApplicationController
  def cmp
    @cmp_case_studies = CSV.foreach(Rails.root.join('data', 'cmp_top_50.csv').to_s, headers: true)
  end
end
