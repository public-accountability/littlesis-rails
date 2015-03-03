class NozaDonationImporter
  attr_accessor :donor, :donation, :recipient, :donor_first, :donor_last, :date, :amount, :amount2, :recipient_name, :donation_cat, :recipient_cat, :raw_name, :is_couple, :collector_list_id, :recipient_match_type

  def initialize(row)
    @id, @first, @last, @donor_first, @donor_last, @date, @amount, @amount2, @recipient_name, @donation_cat, @recipient_cat = @row = row.map { |d| d.nil? ? nil : d.gsub(/[\r\n\s]+/, " ").strip }
    @raw_name = (@first.to_s + " " + @last.to_s).strip
    @is_couple = false
  end

  def import
    return false unless @amount and @recipient_name
    return false unless find_donor
    return false unless find_or_create_recipient
    create_donation
  end

  def find_donor
    # first initial of donor name (or equivalent name) must be a collector first initial
    # return false unless @raw_name.downcase.match(/(^|and\s+|&\s+)#{@donor_first.downcase[0]}/)
    raw_first_initials = @raw_name.downcase.scan(/(^|and\s+|&\s+)(\w)/).transpose[1].uniq
    donor_first_initials = [@donor_first.downcase].concat(Person.same_first_names(@donor_first)).map(&:first).uniq
    matching_first_initials = raw_first_initials & donor_first_initials
    return false unless matching_first_initials.count > 0

    if Entity.exists?(@id)
      @donor = Entity.find(@id)
    else
      # find entity on collector list
      return false unless @donor = List.find(@collector_list_id).entities.find { |e| e.name.downcase.strip == @raw_name.downcase.strip }
    end

    return @donor unless @donor.couple?

    partners = [@donor.couple.partner1, @donor.couple.partner2]

    # see if any partners' first names are short versions of the donor name
    if match = partners.find { |partner| partner.person.name_last.downcase == @donor_last.downcase and Person::SHORT_FIRST_NAMES[partner.person.name_first.downcase] == @donor_first.downcase }
      return @donor = match
    end

    # see if any partners have the same last name and first initial as the donor
    matches = partners.select do |partner|
      partner.person.name_last.downcase == @donor_last.downcase and donor_first_initials.include?(partner.person.name_first.downcase[0])
    end

    if matches.count == 1
      return @donor = matches.first
    end
    
    # both partners have same first initial and last name, so choose the one with the same first name, if any
    donor_first_names = [@donor_first].concat(Person.same_first_names(@donor_first)).map(&:downcase)
    if matches.count == 2 and @donor = matches.find { |partner| donor_first_names.include?(partner.person.name_first.downcase) }
      return @donor
    end

    @donor = nil
    return false
  end

  def find_or_create_recipient
    # exact name match with the most rels
    if @recipient = Entity.orgs
                          .joins(:aliases).joins("LEFT JOIN link ON (link.entity1_id = entity.id)")
                          .select("entity.*, COUNT(DISTINCT(link.id)) AS num_rels")
                          .where("LOWER(entity.name) = ? OR (LOWER(alias.name) = ?)", @recipient_name.downcase, @recipient_name.downcase)
                          .group("entity.id")
                          .order("num_rels DESC")
                          .first
      @recipient_match_type = :exact_name
      return @recipient
    end

    # partial name match with related extensions and the most rels
    # num = @recipient_name.split(/\s+/).count > 3 ? 3 : 2
    # name_like = (@recipient_name.split(/\s+/).take(num).join(" ") + "%").downcase
    # orgs = Entity.orgs.with_exts(['NonProfit', 'Philanthropy'])
    #                       .joins(:aliases).joins("LEFT JOIN link ON (link.entity1_id = entity.id)")
    #                       .select("entity.*, COUNT(DISTINCT(link.id)) AS num_rels")
    #                       .where("LOWER(entity.name) LIKE ? OR LOWER(alias.name) LIKE ?", name_like, name_like)
    #                       .group("entity.id")
    #                       .order("num_rels DESC")
    # if @recipient = recipient_sanity_check(orgs).find { |e| (Org.strip_name(e.name, false).downcase.split(/\s+/) - Org.strip_name(@recipient_name, false).downcase.split(/\s+/)).count == 0 }
    #   @recipient_match_type = :partial_name_with_ext
    #   return @recipient
    # end

    # strip name to meaningful words and search for org with all those words
    stripped = Org.strip_name(@recipient_name, strip_geo = false)
    if stripped.split(/\s+/).count > 1
      orgs = Entity.search "@(name,aliases) #{Riddle::Query.escape(stripped)} @primary_ext Org", per_page: 20, match_mode: :extended, with: { is_deleted: 0 }
      if @recipient = recipient_sanity_check(orgs).find { |e| (Org.strip_name(e.name, false).downcase.split(/\s+/) - stripped.downcase.split(/\s+/)).count == 0 }
        @recipient_match_type = :stripped_name
        return @recipient
      end
    end

    create_recipient
  end

  def recipient_sanity_check(orgs)
    orgs.select do |org|
      lengths = [org.name.length, @recipient_name.length]
      lengths.max/lengths.min.to_f <= 2
    end
  end

  def create_recipient
    @recipient = Entity.create(
      name: @recipient_name,
      primary_ext: 'Org',
      last_user_id: Lilsis::Application.config.system_user_id
    )

    @recipient.add_extension('NonProfit')
    @recipient.add_extension('Cultural') if @recipient_name.match(/\b(arts?|museum|cultural|culture|theater|theatre|film)\b/i)
    @recipeint.add_extension('Philanthropy') if @recipient_name.match(/\b(foundation|fund)\b/i)
    @recipeint.add_extension('School') if @recipient_name.match(/\b(school|college|university)\b/i)
  end

  def parse_date(str)
    return 
    parts = str.split("/")
    parts[2] + "-" + parts[0].rjust(2, "0") + "-" + parts[1].rjust(2, "0")
  end

  def parse_amount(amount)
    return nil if amount.to_i == 0 or amount.blank?
  end

  def create_donation
    @donation = Relationship.create(
      entity1_id: @donor.id,
      entity2_id: @recipient.id,
      category_id: 5, # Donation
      description1: @donation_cat,
      amount: parse_amount(@amount),
      amount2: parse_amount(@amount2),
      start_date: parse_date(@date),
      end_date: parse_date(@date),
      is_current: false,
      last_user_id: Lilsis::Application.config.system_user_id
    )

    @donation.add_reference('http://nozasearch.com', 'NOZA')
  end
end