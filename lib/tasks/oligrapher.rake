# frozen_string_literal: true

namespace :oligrapher do
  desc 'Build oligrapher based on commit or default commit'
  task :build, [:commit, :development] => :environment do |_, args|
    commit = args[:commit].presence || OligrapherAssetsService.latest_commit
    OligrapherAssetsService
      .new(commit, development: args[:development])
      .run
  end
end
