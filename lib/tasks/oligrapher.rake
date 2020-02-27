# frozen_string_literal: true

namespace :oligrapher do
  desc 'Build oligrapher based on commit or default commit'
  task :build, [:commit, :local_api] => :environment do |_, args|
    commit = args[:commit].presence || OligrapherAssetsService.latest_commit
    OligrapherAssetsService
      .new(commit, local_api: args[:local_api])
      .run
  end
end
