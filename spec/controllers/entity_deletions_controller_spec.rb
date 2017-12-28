require 'rails_helper'

describe EntityDeletionsController, type: :controller do
  it { should use_before_action(:authenticate_user!) }
  it { should use_before_action(:set_entity) }
  it { should route(:get, '/entities/1/deletion/review').to(action: :review, id: 1)}
end
