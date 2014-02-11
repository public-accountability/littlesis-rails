namespace :sessions do
  desc "Clear sessions over two weeks old"
  task :clear_expired, [:seconds] => :environment do |t, args|
    args.with_defaults(seconds: 14.days)
    Session.clear_expired(args.seconds.to_i)
  end
end