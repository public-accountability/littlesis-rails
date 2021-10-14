describe FeaturedResource, type: :model do
  it { is_expected.to have_db_column(:entity_id) }
  it { is_expected.to have_db_column(:title) }
  it { is_expected.to have_db_column(:url) }

end
