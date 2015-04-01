class OrgBoardUpdater
  attr_accessor :org, :board_rels, :board_url, :board_title, :attempted_board_urls, :found_board_rels, :session, :board_pages, :possible_board_pages

  URLS_TO_SKIP = ["yahoo.com"]

  def initialize(org, search_engine, session)
    @org = org
    @search_engine = search_engine
    get_board_rels
    @session = session
  end

  def get_board_rels
    @board_rels = @org.relationships.includes({ entity: :person }, :position).where(position: { is_board: true }).to_a
  end

  def board_members
    @board_rels.map(&:entity)
  end

  def update_with_board_page
    @board_pages = find_board_pages
    @attempted_board_urls = []

    @board_pages.each do |p|
      url = p['link']
      @found_board_rels = check_board_page(url, @board_rels)
      @attempted_board_urls << url

      if found_enough
        @board_url = url
        @board_title = p['title']
        break
      end
    end

    return false unless found_enough

    update_board_rels
    sort_board_rels
  end

  def find_board_pages(page = 1)
    q = @org.name + ' board of directors'
    @possible_board_pages = @search_engine.search(q, page).to_a
    @board_pages = select_board_pages(@possible_board_pages)

    unless @board_pages.count > 0 or page > 1
      # try one more page
      match = find_board_pages(page + 1)
    end

    @board_pages
  end

  def select_board_pages(possible_pages)
    possible_pages.select do |r|
      r['title'].match(/board|governance/i) and !r['link'].match(/\.pdf$/) and !URLS_TO_SKIP.find { |str| r['link'].downcase.index(str) }
    end
  end

  def check_board_page(url, rels)
    begin
      @session.visit(url)
      return [] unless body = HTMLEntities.new.decode(@session.body).gsub(/[[:space:]]+/, ' ')
      return [] unless text = @session.text.gsub(/[[:space:]]+/, ' ')
      return [] unless text.match(/board/i) or text.match(/trustees/i)
    rescue => e
      print e.backtrace
      print "\n"
      return []
    end

    found = rels.select do |rel|
      rel.entity.name_regexes(false).find do |regex|
        (matches = body.scan(regex)) and matches.find { |m| text.match(/#{Regexp.quote(m[0])}/mui) }
      end
    end

    # if none found, only require html match
    unless found.present?
      found = rels.select do |rel|
        rel.entity.name_regexes(false).find do |regex|
          body.match(regex)
        end
      end
    end

    found
  end

  def update_board_rels
    found_ids = @found_board_rels.map(&:id)
    @board_rels.each do |rel|
      rel.is_current = found_ids.include?(rel.id)
    end
  end

  def save_changed
    changed.each do |rel|
      rel.save
      rel.add_reference(@board_url, @board_title) rescue nil # in case source url is too long for db
    end
  end

  def sort_board_rels
    @board_rels.sort! { |a, b| a.entity.person.name_last <=> b.entity.person.name_last }
  end

  def unique_found
    (@found_board_rels or []).uniq(&:entity1_id)
  end

  def unique_board_rels
    @board_rels.uniq(&:entity1_id)
  end

  def unique_current_board_rels
    unique_board_rels.select { |r| r.is_current == true }.uniq(&:entity1_id)
  end

  def found_enough
    return false unless unique_found.count > 0
    return false unless unique_found.count > 5 or unique_current_board_rels.count < 8
    unique_found.count > unique_current_board_rels.count/2
  end 

  def expired
    @board_rels.select { |r| r.is_current == false and r.is_current_changed? }
  end

  def made_current
    @board_rels.select { |r| r.is_current == true and r.is_current_changed? }
  end

  def changed
    @board_rels.select { |r| r.changed? }
  end

  def unchanged
    @board_rels.select { |r| !r.is_current_changed? }
  end

  def unchanged_current
    unchanged.select { |r| r.is_current == true }
  end

  def search_url
    @search_engine.search_url
  end
end