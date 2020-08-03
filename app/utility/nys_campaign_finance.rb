# frozen_string_literal: true

module NYSCampaignFinance
  REPORT_ID = {
    'A' => '32 Day Pre Primary',
    'B' => '11 Day Pre Primary',
    'C' => '10 Day Post Primary',
    'D' => '32 Day Pre General',
    'E' => '11 Day Pre General',
    'F' => '27 Day Post General',
    'G' => '32 Day Pre Special',
    'H' => '11 Day Pre Special',
    'I' => '27 Day Post Special',
    'J' => 'Periodic Jan',
    'K' => 'Periodic July',
    'L' => '24 hour Notice'
  }.freeze

  TRANSACTION_CODE = {
    'A' => 'Monetary Contributions Received from: Individuals & Partnerships',
    'B' => 'Monetary Contributions Received from: Corporate',
    'C' => 'Monetary Contributions Received from: All Other',
    'D' => 'In-Kind (Non-Monetary) Contributions Received',
    'E' => 'Other Receipts Received',
    'F' => 'Expenditures/Payments',
    'G' => 'Transfers In',
    'H' => 'Transfers Out',
    'I' => 'Loans Received',
    'J' => 'Loan Repayments',
    'K' => 'Liabilities/Loans Forgiven',
    'L' => 'Expenditure Refunds (Increases Balance)',
    'M' => 'Expenditure Refunded (Decreases Balance)',
    'N' => 'Outstanding Liabilities/Loans',
    'O' => 'Partnerships / Subcontractor',
    'P' => 'Non-Campaign Housekeeping Receipts',
    'Q' => 'Non-Campaign Housekeeping Expenses',
    'R' => 'Expense Allocation Among Candidates'
  }.freeze

  TRANSACTION_CODE_OPTIONS = {
    :contributions => %w[A B C],
    :in_kind => ['D'],
    :expenditures => ['F'],
    :transfers => %w[G H],
    :loans => %w[I J K N],
    :refunds => %w[L M],
    :other => %w[E O P Q R]
  }.freeze

  OFFICES = {
    4 => 'Governor',
    5 => 'Lt. Governor',
    6 => 'Comptroller',
    7 => 'Attorney General',
    8 => 'U.S. Senator',
    9 => 'Sup. Court Justice',
    11 => 'State Senator',
    12 => 'Member of Assembly',
    13 => 'State Committee',
    16 => 'Judicial Delegate',
    17 => 'Alt Judicial Del.',
    18 => 'Chairperson',
    19 => 'City Manager',
    20 => 'Council President',
    21 => 'County Executive',
    22 => 'Mayor',
    23 => 'President',
    24 => 'Supervisor',
    25 => 'Sheriff',
    26 => 'District Attorney',
    27 => 'County Legislator',
    28 => 'County Court Judge',
    29 => 'Surrogate Court Judge',
    30 => 'Family Court Judge',
    31 => 'Party Committee Member',
    32 => 'City Council',
    33 => 'Village Trustee',
    34 => 'Village Justice',
    35 => 'Clerk',
    36 => 'Town Justice',
    37 => 'Town Council',
    38 => 'Receiver of Taxes',
    39 => 'Highway Superintendent',
    40 => 'Alderperson',
    41 => 'Treasurer',
    42 => 'Assessor',
    43 => 'Borough President',
    44 => 'District Leader',
    45 => 'Comptroller',
    46 => 'Coroner',
    47 => 'County Representative',
    49 => 'Public Advocate',
    50 => 'Councilman',
    51 => 'Trustee',
    52 => 'Town Board',
    53 => 'Legislator',
    54 => 'Legislative District',
    55 => 'City Chamberlain',
    56 => 'City Council President',
    57 => 'City Court Judge',
    58 => 'Pres. Common Council',
    59 => 'Clerk/Collector',
    60 => 'Civil Court Judge',
    61 => 'Trustee of School Funds',
    62 => 'County Committee',
    63 => 'Commissioner of Education',
    64 => 'Commissioner of Public Works',
    65 => 'Common Council',
    66 => 'District Court Judge',
    67 => 'Commissioner of Finance',
    68 => "Citizen's Review Board Member",
    69 => 'Town Clerk/Tax Collector',
    70 => 'Town Tax Collector',
    71 => 'Controller',
    72 => 'City School Board',
    73 => 'Collector',
    74 => 'Commissioner of Schools',
    75 => 'County Clerk',
    76 => 'Town Clerk',
    77 => 'Village Clerk',
    78 => 'County Treasurer',
    79 => 'Town Treasurer',
    80 => 'Village Treasurer',
    81 => 'City Treasurer',
    82 => 'Town Supervisor'
  }.freeze

  def self.committee_type_description(type)
    case type
    when '1'
      'Individual'
    when '2'
      'PAC'
    when '3', '4', '5', '6', '7'
      'Constituted/Party'
    when '3H', '4H', '5H', '6H', '7H'
      'Constituted/Party Campaign Finance Registration Form'
    when '8'
      'Independent Expenditure'
    when '9'
      'Authorized Multi-Candidate'
    when '9B'
      'Ballot Issue'
    end
  end
end
