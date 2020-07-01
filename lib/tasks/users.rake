namespace :users do

  desc 'recent signups since date'
  task :recent_signups, [:date] => :environment do |_, args|
    since = DateTime.parse(args[:date])
    file_path = Rails.root.join('data', "recent_signups_since_#{since.strftime('%F')}.csv")

    users = User
              .where(is_restricted: false)
              .where("created_at >= ?", since)
              .order('created_at DESC')
              .map(&:attributes)
              .map { |attrs| attrs.slice('username', 'email', 'map_the_power', 'created_at') }


    Utility.save_hash_array_to_csv file_path, users

    ColorPrinter.print_blue "#{users.count} users saved to #{file_path.to_s}"
  end

end
