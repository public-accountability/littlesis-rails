describe MergeController, type: :controller do
  describe "routes" do
    it { is_expected.to route(:get, '/entities/merge').to(action: :merge) }
    it { is_expected.to route(:post, '/entities/merge').to(action: :merge!) }
    it { is_expected.to route(:get, '/entities/merge/redundant').to(action: :redundant_merge_review) }
  end
end
