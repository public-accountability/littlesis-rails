# frozen_string_literal: true

class NyDisclosure < ApplicationRecord
  has_one :ny_match, inverse_of: :ny_disclosure, dependent: :destroy
  belongs_to :ny_filer,
             class_name: 'NyFiler',
             foreign_key: 'filer_id',
             primary_key: 'filer_id',
             inverse_of: :ny_disclosures,
             optional: true

  validates :filer_id, presence: true
  validates :report_id, presence: true
  validates :transaction_code, presence: true
  validates :e_year, presence: true
  validates :transaction_id, presence: true
  validates :schedule_transaction_date, presence: true

  ThinkingSphinx::Callbacks.append(self, :behaviours => [:sql, :deltas])

  def full_name
    return corp_name if corp_name.present?
    return nil if first_name.nil? && last_name.nil?
    middle_name = mid_init.nil? ? ' ' : " #{mid_init} "
    "#{first_name}#{middle_name}#{last_name}".titleize
  end

  def is_matched
    ny_match.present?
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
    "#{e_year} NYS Board of Elections Financial Disclosure Report: #{NYSCampaignFinance::REPORT_ID[report_id]}"
  end

  #################
  # CLASS METHODS #
  #################

  # <Entity> -> Hash
  def self.potential_contributions(entity)
    search(search_terms(entity),
           :with => { :is_matched => false, :transaction_code => ['A', 'B', 'C'] },
           :sql => { :include => :ny_filer },
           :per_page => 500)
      .map(&:contribution_attributes)
  end

  # <Entity> -> String
  # Creates variations on an entity's name and aliases for improved matching with sphinx
  def self.search_terms(entity)
    LsSearch.generate_search_terms(entity)
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
    when 'A'
      'A (Individual/Partnership)'
    when 'B'
      'B (Corporate)'
    when 'C'
      'C (All/Other)'
    when 'D'
      'D (In-kind)'
    else
      transaction_code
    end
  end

  def format_address
    look_nice = lambda { |x| x.to_s.titleize }
    [look_nice.call(address), look_nice.call(city) + ',', state.to_s, zip.to_s].join(' ')
  end
end
