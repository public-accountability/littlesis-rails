# frozen_string_literal: true

=begin

id         |
updated_at |
created_at |
name       | string         | name of the dataset
row_data   | longtext(json) | contains the actual "data" as json object
row_id     | 
matched    | boolean        | if the row has been matched yet 
match_data | longtext(json) | pre-calculated match data



=end


class ExternalDataset < ApplicationRecord

  
end



