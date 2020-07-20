namespace :users do
  desc 'recent signups since date'
  task :recent_signups, [:date] => :environment do |_, args|
    since = DateTime.parse(args[:date])
    file_path = Rails.root.join('data', "recent_signups_since_#{since.strftime('%F')}.csv")

    users = User
              .includes(:user_profile)
              .where(is_restricted: false)
              .where('created_at >= ?', since)
              .order('created_at DESC')
              .map do |user|
                user
                  .attributes
                  .slice('username', 'email', 'map_the_power', 'created_at')
                  .merge!('reason' => user.user_profile&.reason)
              end

    Utility.save_hash_array_to_csv file_path, users

    ColorPrinter.print_blue "#{users.count} users saved to #{file_path}"
  end
end
