class NyDisclosure < ApplicationRecord
  REPORT_ID = {
    "A" => "32 Day Pre Primary",
    "B" => "11 Day Pre Primary",
    "C" => "10 Day Post Primary",
    "D" => "32 Day Pre General",
    "E" => "11 Day Pre General",
    "F" => "27 Day Post General",
    "G" => "32 Day Pre Special",
    "H" => "11 Day Pre Special",
    "I" => "27 Day Post Special",
    "J" => "Periodic Jan",
    "K" => "Periodic July",
    "L" => "24 hour Notice"
  }.freeze
  
  has_one :ny_match, inverse_of: :ny_disclosure
  belongs_to :ny_filer, class_name: "NyFiler", foreign_key: "filer_id", primary_key: "filer_id"

  validates_presence_of :filer_id,
                        :report_id,
                        :transaction_code,
                        :e_year,
                        :transaction_id,
                        :schedule_transaction_date

  def full_name
    return corp_name if corp_name.present?
    return nil if first_name.nil? && last_name.nil?
    middle_name = mid_init.nil? ? " " : " #{mid_init} "
    "#{first_name.to_s}#{middle_name}#{last_name.to_s}".titleize
  end

  def is_matched
    !ny_match.blank?
  end

  def contribution_attributes
    {
      name: full_name,
      address: format_address,
      date: original_date.nil? ? schedule_transaction_date : original_date,
      amount: amount1,
      filer_id: filer_id,
      filer_name: ny_filer.name.titleize,
      transaction_code: format_transaction_code,
      disclosure_id: id
    }
  end

  def reference_link
    "http://www.elections.ny.gov:8080/reports/rwservlet?cmdkey=efs_sch_report&p_filer_id=#{filer_id}&p_e_year=#{e_year}&p_freport_id=#{report_id}&p_transaction_code=#{transaction_code}"
  end

  def reference_name
    "#{e_year} NYS Board of Elections Financial Disclosure Report: #{NyDisclosure::REPORT_ID[report_id]}"
  end

  #################
  # CLASS METHODS #
  #################

  # <Entity> -> Hash
  def self.potential_contributions(entity)
    search(search_terms(entity),
           :with => { :is_matched => false, :transaction_code =>  [ "'A'", "'B'", "'C'" ] },
           :sql => { :include => :ny_filer },
           :per_page => 500
          ).map(&:contribution_attributes)
  end

  # <Entity> -> String
  # Creates variations on an entity's name and aliases for improved matching with sphinx
  def self.search_terms(entity)
    search_terms = Set.new

    entity.aliases.each do |a|
      search_terms << a.name

      if entity.person?
        name_h = NameParser.parse_to_hash(a.name)                         # get parsed name
        search_terms << (name_h[:name_first] + " " + name_h[:name_last])  # Add only first + last
        search_terms << (name_h[:name_nick] + " " + name_h[:name_last]) if name_h[:name_nick].present?
      end

      search_terms << Org.strip_name(a.name) if entity.org?
    end

    if search_terms.length > 1
      search_terms.to_a.map { |t| "(#{t})" }.join(" | ")
    else
      search_terms.to_a[0]
    end
  end

  def self.update_delta_flag(ids)
    where(id: ids).each do |e|
      e.delta = true
      e.save
    end
  end

  private 

  def format_transaction_code
    case transaction_code
    when "A"
      "A (Individual/Partnership)"
    when "B"
      "B (Corporate)"
    when "C"
      "C (All/Other)"
    when "D"
      "D (In-kind)"
    else
      transaction_code
    end
  end

  def format_address
    look_nice = lambda { |x| x.to_s.titleize }
    [ look_nice.call(address), look_nice.call(city) + ',', state.to_s, zip.to_s ].join(' ')
  end
end
