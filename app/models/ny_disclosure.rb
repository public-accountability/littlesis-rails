class NyDisclosure < ActiveRecord::Base
  has_one :ny_match, inverse_of: :ny_disclosure
  belongs_to :ny_filer, class_name: "NyFiler", foreign_key: "filer_id", primary_key: "filer_id"

  def full_name
    if corp_name.present?
      corp_name
    else
      unless first_name.nil? and last_name.nil?
        middle_name = mid_init.nil? ? " " : " #{mid_init} "
        "#{first_name.to_s}#{middle_name}#{last_name.to_s}".titleize
      end
    end
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

  def self.potential_contributions(name)
    search(name, :with => { :is_matched => false }, :sql => { :include => :ny_filer } ).map(&:contribution_attributes)
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
