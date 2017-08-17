class NyFiler < ActiveRecord::Base
  has_one :ny_filer_entity
  has_many :entities, :through => :ny_filer_entity
  has_many :ny_disclosures, foreign_key: "filer_id"

  validates_presence_of :filer_id
  validates_uniqueness_of :filer_id

  def is_matched?
    ny_filer_entity.present?
  end

  def office_description
    OFFICES[office]
  end
  
  #---------------#
  # Class methods #
  #---------------#

  def self.search_filers(name)
    search_by_name_and_committee_type(name, ["'1'", "''"])
  end

  def self.search_pacs(name)
    search_by_name_and_committee_type(name, ["'2'", "'9'", "'8'"])
  end
    
  # str, [ str ] => <ThinkingSphinx::Search>
  private_class_method def self.search_by_name_and_committee_type(name, committee_types)
    NyFiler.search( name, 
                    :sql => { :include => :ny_filer_entity },
                    :with => {:committee_type => committee_types } )
  end
  
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


  
end
