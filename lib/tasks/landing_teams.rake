require Rails.root.join('lib', 'task-helpers', 'landing_teams.rb')

namespace :landing_teams do
  desc 'uploads the landing teams'
  task upload: :environment do
    LandingTeams.upload
  end
end
