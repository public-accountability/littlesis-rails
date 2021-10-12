describe 'relationships/show.html.erb', :tag_helper, type: :view do
  seed_tags

  before(:all) do
    @user = build(:user)
    @rel = build(:relationship, category_id: 1, description1: 'boss', id: 123, updated_at: Time.now)
    @rel.position = build(:position, is_board: false)
    @rel.last_user = @user
  end

  # remove this when the admin only view constraint is removed
  before(:each) do
    allow(view).to receive(:user_admin?).and_return(true)
  end

  def mock_current_user_permissions
    permissions = double('permisions')
    allow(permissions).to receive(:relationship_permissions)
                            .and_return({deleteable: false})

    allow(permissions).to receive(:tag_permissions).and_return({})
    allow(permissions).to receive(:uploader?).and_return(false)

    allow(view).to receive(:current_user)
                     .and_return(double('user',
                                        has_legacy_permission: true,
                                        permissions: permissions))
  end

  describe 'layout' do
    let(:user_signed_in) { false }
    let(:tags) { Tag.all.take(2) }

    before(:each) do
      assign(:relationship, @rel)
      expect(@rel).to receive(:documents).and_return([])
      allow(@rel).to receive(:tags).and_return(tags)
      allow(view).to receive(:user_signed_in?).and_return(user_signed_in)
    end

    context 'anon user view relationship page with 2 tags' do
      before { render }
      it 'has title' do
        css 'h1', :text => "Position: Human Being, mega corp LLC"
      end

      xit 'has subtitle' do
        css 'h4 a', :count => 2
      end

      it 'has source links table' do
        css '#source-links-table', :count => 1
      end

      it { is_expected.to render_template("relationships/_subtitle") }
      it { is_expected.to render_template("relationships/_details") }
      it { is_expected.to render_template("relationships/_sources") }

      describe 'actions' do
        it 'has actions div' do
          css '#actions'
        end

        it 'has edited history' do
          css '#entity-edited-history'
          css 'a', :text => @user.username
        end
      end

      it 'has tags-container div' do
        css '#tags-container'
      end

      it 'has tags title' do
        css 'h4', text: 'Tags'
      end
    end

    context 'anon user and the relationship has no tags' do
      let(:tags) { [] }
      before { render }

      it 'does not have the tags-container div' do
        not_css '#tags-container'
      end

      it 'does not have the tags title' do
        not_css 'h4', text: 'Tags'
      end
    end

    context 'signed in user' do
      let(:user_signed_in) { true }

      before do
        mock_current_user_permissions
        render
      end

      context 'relationship has tags' do
        it 'has tags-controls' do
          css '#tags-controls'
          css '#tags-controls #tags-edit-button'
        end
      end

      context 'relationship has no tags' do
        let(:tags) { [] }

        it 'has tags-controls' do
          css '#tags-controls'
          css '#tags-controls #tags-edit-button'
        end

        it 'has tags title' do
          css 'h4', text: 'Tags'
        end
      end
    end
  end

  describe 'Add Reference Modal' do
    let(:relationship) do
      build(:relationship, category_id: 1, description1: 'boss', updated_at: Time.current)
    end

    before do
      assign(:relationship, relationship)
      mock_current_user_permissions
      allow(view).to receive(:user_signed_in?).and_return(true)
      render
    end

    it 'has modal and form' do
      css '#add-reference-modal'
      css 'form#reference-form', :count => 1
    end

    it 'has hidden inputs' do
      css 'input[value="Relationship"]', :count => 1
      css 'input#data_referenceable_id', :count => 1
    end

    it 'has url field' do
      css 'input[type="url"]', :count => 1
    end

    it 'has 2 text fields' do
      css 'input[type="text"]', :count => 2
    end

    it 'has text area' do
      css 'textarea', :count => 1
    end

    it 'has close and submit buttons' do
      css 'button', :text => 'Close'
      css 'button[type="submit"]', :text => 'Submit', :count => 1
    end
  end
end
