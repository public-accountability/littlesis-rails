require "rails_helper"

describe NotableEntities do
  specify { expect(NotableEntities).to be_a ActiveSupport::HashWithIndifferentAccess }
  specify { expect(NotableEntities.fetch(:senate)).to eq 12_885 }
  specify { expect(NotableEntities.fetch('democratic_party')).to eq 12_886 }
  specify { expect(NotableEntities.keys).to be_a Array }
end
