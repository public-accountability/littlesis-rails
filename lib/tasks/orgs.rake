namespace :orgs do
  desc "get missing company SEC CIKs using tickers"
  task :update_boards, [:limit, :offset, :only_sec] => [:environment] do |task, args|
    if org_id = ENV['ORG_ID']
      orgs = [Entity.find(org_id.to_i)]
    else
      args = args.to_hash
      only_sec = (args.fetch(:only_sec, "true") == "true")

      # all orgs with board relationships
      orgs = Entity.orgs.joins(relationships: :position).where(relationship: { category_id: 1 }, position: { is_board: true }).group("entity.id").limit(args.fetch(:limit, 100)).offset(args.fetch(:offset, 0))

      # only sec boards
      orgs = orgs.joins(:public_company).where.not(public_company: { sec_cik: nil }) if only_sec
        
      print "updating boards of #{orgs.count.count} orgs...\n"
    end

    session = Capybara::Session.new(:selenium)

    CSV.open("data/org-board-updates.csv", 'a') do |csv|
      orgs.each_with_index do |org, i|
        print "#{i+1} of #{orgs.count.count}\n"
        print "---------- #{org.name} ----------\n\n"

        task_meta_query = { task: task.to_s, namespace: org.id, predicate: "updated_at" }
        skip_if_run_since = 1.month.ago.to_time

        if task_meta = TaskMeta.where(task_meta_query).where("value > ?", skip_if_run_since).first
          print "already updated on #{task_meta.value.to_s}\n\n"
          next
        end

        updater = OrgBoardUpdater.new(org, GoogleSearch.new, session)
        updater.update_with_board_page

        if updater.attempted_board_urls.count > 0
          print "scraped board pages:\n"
          print updater.attempted_board_urls.join("\n") + "\n\n"

          if updater.found_enough
            print "expired:\n" + updater.expired.map { |r| "- " + r.entity.name }.join("\n") + "\n"
            print "made current:\n" + updater.made_current.map { |r| "+ " + r.entity.name }.join("\n") + "\n"
            print "unchanged current:\n" + updater.unchanged_current.map { |r| "* " + r.entity.name }.join("\n") + "\n"
            print "\n"

            updater.save_changed
          else

            print "only found #{updater.found_board_rels.count} board members!\n"
            print updater.found_board_rels.map { |r| "* " + r.entity.name }.join("\n") + "\n"
          end
        else
          print "couldn't find board page!\n\n"
        end

        task_meta = TaskMeta.find_or_initialize_by(task_meta_query)
        task_meta.value = Time.now
        task_meta.save

        unless org_id
          csv << [
            "http://littlesis.org" + org.legacy_url,
            updater.found_enough, 
            updater.expired.map(&:entity).map(&:name).uniq.join(", "), 
            updater.board_url
          ]
        end
      end
    end
  end
end