# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength

PAC_NAMES = <<~TXT
  %Court Officers%
  %CORRECTION OFFICERS%
  %Police Officers%
  %Officers Association%
  %Detectives Association%
  %SHERIFF%ASSOCIATION%
  %Patrolmen%
  %POLICE%
  PBA%
  Correction Officers Benevolent Association%
  Nassau County Corrections Officers%
  Suffolk County Correction Officers%
  Westchester County Correction Officers%
  COBANC%
  NYSCOPBA%
  Captain%Endowment%
  Detectives Ass%
  National NYCPD%
  NYC Deputy Sheriff%
  NYC DETECTIVE%
  NYC PATROLMEN%
  NYC PBA%
  NYC POLICE BENEVOLENT%
  NYC SERGEANTS BENEVOLENT%
  NYC RETIRED POLICE OFFICERS%
  NYC RETIRED TRANSIT OFFICERS%
  NYC RETIRED TRANSIT PO ASSOC%
  NYS Association of PBA%
  NYS Troopers%
  NYSPIA%
  NYCPD VERRAZANO%
  PA Police%
  Port Authority PBA%
  SERGEANTS BENEVOLENT%
  SERGEANTS%
TXT

ATTRIBUTES = %w[id filer_id report_id transaction_code e_year transaction_id schedule_transaction_date original_date contrib_code corp_name address city state zip amount1 description].freeze

CONDITIONS = PAC_NAMES
               .split("\n")
               .map { |x| NyDisclosure.arel_table[:corp_name].matches(x) }
               .reduce(:or)

def save(filename, results)
  file = Rails.root.join('data', filename).to_s
  ColorPrinter.print_cyan "Saving #{results.size} records to #{file}"
  Utility.save_hash_array_to_csv(file, results)
end

def get_filer(filer_id)
  @filers ||= {}

  unless @filers[filer_id]
    @filers[filer_id] = NyFiler.find_by(filer_id: filer_id)
  end

  if @filers[filer_id].nil?
    ColorPrinter.print_red "missing filer: #{filer_id}"
    return Struct.new(:name).new('')
  end

  @filers[filer_id]
end

def disclosures
  NyDisclosure
    .includes(ny_filer: [:ny_filer_entity])
    .where(transaction_code: 'C')
    .where(CONDITIONS)
    .order('corp_name')
    .map do |ny_disclosure|

    ny_disclosure.attributes
      .slice(*ATTRIBUTES)
      .merge!(url: ny_disclosure.reference_link,
              recipient_name: ny_disclosure.ny_filer&.name,
              recipient_littlesis_id: ny_disclosure.ny_filer&.ny_filer_entity&.entity&.id)
  end
end

def group_by_donor_and_filer
  NyDisclosure
    .select('corp_name',
            'filer_id',
            'count(*) AS disclosure_count',
            'SUM(amount1) as total_amount',
            'MIN(e_year) as first_donation_year',
            'MAX(e_year) as latest_donation_year')
    .where(transaction_code: 'C')
    .where(CONDITIONS)
    .group('corp_name', 'filer_id')
    .order('total_amount DESC')
    .map do |query|

    query
      .attributes
      .without('id')
      .merge!(filer_name: get_filer(query['filer_id']).name)
  end
end

def group_by_recipient
  NyDisclosure
    .select('filer_id',
            'count(*) AS disclosure_count',
            'SUM(amount1) as total_amount')
    .where(transaction_code: 'C')
    .where(CONDITIONS)
    .group('filer_id')
    .order('total_amount DESC')
    .map do |query|

    query
      .attributes
      .without('id')
      .merge!(filer_name: get_filer(query['filer_id']).name)
  end
end

save 'nys_police_money_disclosures.csv', disclosures
save 'nys_police_money_grouped_by_donor_and_recipient.csv', group_by_donor_and_filer
save 'nys_police_money_grouped_by_recipient.csv', group_by_recipient

# rubocop:enable Metrics/MethodLength
