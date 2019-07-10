# frozen_string_literal: true

# The term "IapdOwner" here is shorthand for executive and/or owner
class IapdDatum < ExternalDataset
  IAPD_TAG_ID = 18
  IapdAdvisor = Struct.new(:crd_number, :name, :data)
  IapdOwner = Struct.new(:owner_key, :name, :associated_advisors, :data) do
    def owner_type
      owner_types = data.map { |d| d['owner_type'] }.uniq
      if owner_types.length != 1 && owner_types.include?('I')
        Rails.logger.warn "Conflicting owner type in Iapd dataset. Ownerkey = #{owner_key}"
        nil
      else
        owner_types.first == 'I' ? :person : :org
      end
    end
  end

  UNMATCHED_ADVISOR_QUEUE = CacheQueue.new(name: 'unmatched_advisors_ids')

  OWNERS_MATCHING_QUEUE = CacheQueue.new(name: 'iapd_owners')

  def filing_ids
    row_data['data'].map { |x| x.fetch('filing_id') }.uniq
  end

  # Returns CRD numbers of the advisors for the given owner
  # see IapdImporter.owner_to_struct
  # --> [Int]
  def associated_advisors
    method_only_for! :owner

    row_data.fetch('associated_advisors')
  end

  # This removes all schedule B (indirect owners) filings
  # We'll likely want to import that data at some point.
  def filings
    method_only_for! :owner

    row_data['data'].delete_if { |x| x['schedule'] == 'B' }
  end

  def filings_for_advisor(crd_number)
    method_only_for! :owner

    filings.filter { |x| x['advisor_crd_number'] == crd_number }
  end

  def latest_filing_for_advisor(crd_number)
    method_only_for! :owner

    filings_for_advisor(crd_number).max_by { |x| x['filename'] }
  end

  def add_to_matching_queue
    method_only_for! :owner

    OWNERS_MATCHING_QUEUE.add id, uniq: true
    self
  end

  # currently, we only want owners added to the queue if they meet these conditions:
  #   - not yet matched
  #   - is a person
  #   - contains at least one schedule A filing
  def queueable?
    method_only_for! :owner

    unmatched? && person? && filings.present?
  end

  # Integer --> Boolean
  def queueable_for?(crd_number)
    method_only_for! :owner

    raise Exceptions::LittleSisError unless associated_advisors.include?(crd_number)

    row_data['data'].find { |x| x['advisor_crd_number'] == crd_number }.fetch('schedule') == 'A'
  end

  def iapd_data
    return @_iapd_data if defined?(@_iapd_data)

    if owner?
      @_iapd_data = IapdOwner.new(*row_data.values_at('owner_key', 'name', 'associated_advisors', 'data'))
    elsif advisor?
      @_iapd_data = IapdAdvisor.new(*row_data.values_at('crd_number', 'name', 'data'))
    end
  end

  # Retrieves associated owners for the advisor.
  # --> [IapdDatum]
  def owners
    method_only_for! :advisor

    @_owners ||= self.class.owners_of_crd_number(row_data.fetch('crd_number'))
  end

  def advisors
    method_only_for! :owner

    @_advisors ||= self.class.advisors_by_crd_numbers(row_data.fetch('associated_advisors'))
  end

  # For owners, it returns unmatched advisors
  # For advisors, it returns unmatched owners
  def related_unmatched
    method = owner? ? :advisors : :owners
    public_send(method).unmatched
  end

  def owner?
    row_data_class == IapdOwner.name
  end

  def advisor?
    row_data_class == IapdAdvisor.name
  end

  def as_json(options = nil)
    if owner?
      # creates hash with these fields: crd_number, name, id, dataset_key
      associated_advisors_details = advisors
                                      .map { |a| a.row_data.slice('crd_number', 'name').merge('id' => a.id, 'dataset_key' => a.dataset_key) }

      super(options)
        .deep_merge('row_data' => { 'associated_advisors' => associated_advisors_details })
    else
      super(options)
    end
  end

  ## Class Query Methods ##

  def self.owners
    where(Arel.sql("JSON_VALUE(row_data, '$.class') = 'IapdDatum::IapdOwner'"))
  end

  def self.advisors
    where(Arel.sql("JSON_VALUE(row_data, '$.class') = 'IapdDatum::IapdAdvisor'"))
  end

  def self.assets_under_management_over(amount)
    TypeCheck.check amount, Integer

    where(
      Arel.sql("CAST(JSON_VALUE(row_data, '$.data[0].assets_under_management') as INT) >= #{amount}")
    )
  end

  def self.owners_of_crd_number(crd_number)
    owners.where(Arel.sql("JSON_CONTAINS(row_data, #{crd_number}, '$.associated_advisors')"))
  end

  # The dataset_key for an advisors is always the crd number
  def self.advisors_by_crd_numbers(crd_numbers)
    advisors.where dataset_key: Array.wrap(crd_numbers).map(&:to_s)
  end

  def self.next(flow)
    case flow.to_sym
    when :advisors
      random_unmatched_advisor
    when :owners
      owners_from_queue
    else
      raise Exceptions::LittleSisError, 'Unknown IAPD flow type'
    end
  end

  # This is a perfectly working (and nicer looking)
  # of random_unmatched_advisor....but it takes a long time.
  # If we ever switch to postgres, we can probably
  # index the json field and speed up this query.
  #
  # def self.random_unmatched_advisor
  #   unmatched
  #     .advisors
  #     .assets_under_management_over(3_000_000_000)
  #     .order(Arel.sql('RAND()'))
  #     .first
  # end

  def self.random_unmatched_advisor
    random_id = UNMATCHED_ADVISOR_QUEUE.random_get
    # If no item is in the queue, repopulate it
    if random_id.nil?
      if UNMATCHED_ADVISOR_QUEUE.set(priority_unmatched_advisors_ids).empty?
        Rails.logger.warn 'There are NO MORE unmatched iapd advisors with assets over 3,000,000,000'
        # return an unmatched advisor (regardless of asset size) straight from the database
        return unmatched.advisors.order(Arel.sql('RAND()')).first
      else
        return random_unmatched_advisor
      end
    end

    # Find the advisor and return, only if the advisor is unmatched
    advisor = IapdDatum.find(random_id)
    return advisor if advisor.unmatched?

    # If our advisor has already been matched, remove the matched advisor
    # from the queue, reset the cache, and recurse
    UNMATCHED_ADVISOR_QUEUE.remove(random_id)
    random_unmatched_advisor
  end

  def self.priority_unmatched_advisors_ids
    unmatched
      .advisors
      .assets_under_management_over(3_000_000_000)
      .pluck(:id)
  end

  def self.owners_from_queue
    random_id = OWNERS_MATCHING_QUEUE.random_get
    raise Exceptions::LittleSisError, 'IAPD Owners Queue is empty' if random_id.nil?

    iapd_owner = IapdDatum.find(random_id)
    if iapd_owner.matched?
      OWNERS_MATCHING_QUEUE.remove(random_id)
      owners_from_queue
    else
      iapd_owner
    end
  end

  def self.search(term, type:)
    raise ArgumentError unless %w[owner advisor].include?(type.to_s)

    ExternalDataset.search term,
                           :indices => ['external_dataset_iapd_core'],
                           :with => { iapd_type: type.to_s }
  end

  ## Class Helper Methods ##

  def self.link_to_pdf(crd_number)
    "https://www.adviserinfo.sec.gov/IAPD/content/ViewForm/crd_iapd_stream_pdf.aspx?ORG_PK=#{crd_number}"
  end

  def self.document_attributes_for_form_adv_pdf(crd_number)
    { url: link_to_pdf(crd_number),
      name: "Form ADV: #{crd_number}" }
  end

  private

  def method_only_for!(iapd_type)
    case iapd_type
    when :owner
      raise Exceptions::LittleSisError, 'Ipad Owner method called on an advisor' if advisor?
    when :advisor
      raise Exceptions::LittleSisError, 'Ipad Advisor method called on an owner' if owner?
    else
      raise ArgumentError
    end
  end
end
