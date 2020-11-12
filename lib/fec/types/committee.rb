# frozen_string_literal: true

module FEC
  module Types
    class Committee < Base
      self.map = {
        'C' => :communication_cost,
        'D' => :delegate,
        'E' => :electioneering,
        'H' => :house,
        'I' => :independent_expenditor,
        'N' => :pac_nonqualifed,
        'O' => :super_pac,
        'P' => :presidential,
        'Q' => :pac_qualified,
        'S' => :senate,
        'U' => :single_candiate_independent_expenditure,
        'V' => :pac_with_non_contribution_account_nonqualifed,
        'W' => :pac_with_non_contribution_account_qualified,
        'X' => :party_nonqualified,
        'Y' => :party_qualified,
        'Z' => :national_party_nonfederal_account
      }
    end
  end
end
