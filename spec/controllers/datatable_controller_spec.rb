require 'rails_helper'

describe DatatableController, type: :controller do
  it { is_expected.to route(:get, '/datatable/entity/123').to(action: :entity, id: '123') }
  it { is_expected.not_to route(:get, '/datatable/entity/bad_id').to(action: :entity, id: 'bad_id') }
end
