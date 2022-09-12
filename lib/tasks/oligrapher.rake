# frozen_string_literal: true

namespace :oligrapher do
  desc 'Build oligrapher based on commit or configured in'
  task :build, [:commit] => :environment do |_, args|
    commit = args[:commit].presence || Rails.application.config.littlesis.oligrapher_commit
    OligrapherAssetsService.run(commit)
  end
end
