# frozen_string_literal: true

# This adds custom methods to PaperTrail::Version
# see https://github.com/paper-trail-gem/paper_trail#6-extensibility
module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern

    def self.test_class_method
      puts 'ah ha!'
    end
  end
end
