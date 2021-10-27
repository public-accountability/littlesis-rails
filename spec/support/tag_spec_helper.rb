# frozen_string_literal: true

module TagSpecHelper
  OIL_TAG = { 'name' => 'oil',
              'description' => 'the reason for our planet\'s demise',
              'id' => 1 }

  NYC_TAG = { 'name' => 'nyc',
              'description' => 'anything related to New York City',
              'id' => 2,
              'restricted' => true }

  FINANCE_TAG = { 'name' => 'finance',
                  'description' => 'banks and such',
                  'id' => 3 }

  TAGS = [OIL_TAG, NYC_TAG, FINANCE_TAG]
end
