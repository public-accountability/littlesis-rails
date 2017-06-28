require 'rails_helper'

describe RelationshipsController, type: :controller do
  describe 'post bulk_add' do
    describe 'logined user with importer permission' do
      login_user

      it 'sends error message if given bad reference' do
        post :bulk_add, relationships: [], category_id: 1, reference: { source: '', name: 'important source' }
        expect(response.status).to eq 400
      end

      context 'When submitting two good relationships' do
        before do
          @e1 = create(:corp)
          @e2 = create(:corp)
        end
        let(:relationship1) do
          { 'name' => 'jane doe',
            'blurb' =>  nil,
            'primary_ext' => 'Person',
            'amount' => 500,
            'description1' => 'contribution',
            'start_date' => '2017-01-01',
            'end_date' => nil,
            'is_current' => nil }
        end
        let(:relationship2) do
          { 'name' => @e2.id,
            'blurb' =>  nil,
            'primary_ext' => 'Org',
            'amount' =>  1000,
            'description1' => 'contribution',
            'start_date' => nil,
            'end_date' => nil,
            'is_current' => nil }
        end
        let(:params) do
          { 'entity1_id' => @e1.id,
            'category_id' => 5,
            'reference' => { 'source' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship1, relationship2] }
        end

        it 'should return status 201' do
          post :bulk_add, params
          expect(response.status).to eql 200
        end

        # one entity is new, one isn't
        it 'creates one new entity' do
          expect { post :bulk_add, params }.to change { Entity.count }.by(1)
        end

        it 'creates two relationsips' do
          expect { post :bulk_add, params }.to change { Relationship.count }.by(2)
        end

        it 'creates two donations' do
          expect { post :bulk_add, params }.to change { Donation.count }.by(2)
        end

        it 'creates two References' do
          expect { post :bulk_add, params }.to change { Reference.count }.by(2)
          expect(Reference.last(2).map(&:source)).to eql ['http://example.com'] * 2
        end
      end

      context 'When submitting Relationship with category field' do
        before { @e1 = create(:corp) }

        let(:relationship1) do
          { 'name' => 'Jane Doe',
            'blurb' => nil,
            'primary_ext' => 'Person',
            'description1' => 'board member',
            'start_date' => '2017-01-01',
            'is_board' => true,
            'end_date' => nil,
            'is_current' => '?' }
        end
        let(:params) do
          { 'entity1_id' => @e1.id,
            'category_id' => 1,
            'reference' => { 'source' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship1] }
        end

        it 'creates one relationship' do
          expect { post :bulk_add, params }.to change { Relationship.count }.by(1)
        end

        it 'creates one Position' do
          expect { post :bulk_add, params }.to change { Position.count }.by(1)
          expect(Position.last.relationship.entity2_id).to eql @e1.id
        end

        it 'updates position' do
          post :bulk_add, params
          expect(Position.last.is_board).to eql true
        end
      end

      context 'bad relationship data' do
        before { @e1 = create(:corp) }
        let(:relationship1) do
          { 'name' => 'Jane Doe',
            'blurb' => nil,
            'primary_ext' => 'Person',
            'description1' => 'board member',
            'start_date' => 'this is not a real date' }
        end
        let(:params) do
          { 'entity1_id' => @e1.id,
            'category_id' => 12,
            'reference' => { 'source' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship1] }
        end

        it 'does not create a relationship' do
          expect { post :bulk_add, params }.not_to change { Relationship.count }
        end

        it 'responds with 422' do
          expect { post :bulk_add, params }.not_to change { Relationship.count }
          expect(response.status).to eql 200
        end
      end

      context 'one good relationsihp json and one bad realtionship json' do
        let(:relationship1) do
          { 'name' => 'jane doe',
            'blurb' =>  nil,
            'primary_ext' => 'Person',
            'start_date' => '2017-01-01',
            'end_date' => nil,
            'is_current' => nil }
        end
        let(:relationship2) do
          {'name' => 'evil corp',
           'blurb' => nil,
           'primary_ext' => 'Org',
           'start_date' => 'this is not a real date',
           'end_date' => nil,
           'is_current' => nil }
        end
        let(:params) do
          { 'entity1_id' => create(:corp).id,
            'category_id' => 12,
            'reference' => { 'source' => 'http://example.com', 'name' => 'example.com' },
            'relationships' => [relationship1, relationship2] }
        end

        it 'creates one relationship' do
          expect { post :bulk_add, params }.to change { Relationship.count }.by(1)
        end

        it 'responds with 200' do
          post :bulk_add, params
          expect(response.status).to eql 200
        end
      end

      context 'When submitting position relationships' do
        before do
          @corp = create(:corp)
          @person = create(:person)
          @relationship = { 'name' => @person.id, 'primary_ext' => 'Person', 'start_date' => '2017-01-01' }

          @params = { 'entity1_id' => @corp.id,
                      'category_id' => 1,
                      'reference' => { 'source' => 'http://example.com', 'name' => 'example.com' },
                      'relationships' => [@relationship] }
        end

        it 'creates relationship' do
          expect { post :bulk_add, @params }.to change { Relationship.count }.by(1)
        end

        it 'reverses entity id correctly' do
          post :bulk_add, @params
          rel = Relationship.last
          expect(rel.category_id).to eql 1
          expect(rel.entity.primary_ext).to eql 'Person'
          expect(rel.related.primary_ext).to eql 'Org'
        end
      end

      describe 'it will rollback entity transaction if an ActiveRecord Error occur' do
        let(:generic_relationship) do
          { 'name' => 'new entity',
            'blurb' =>  nil,
            'primary_ext' => 'Org',
            'amount' =>  nil,
            'description1' => 'd1',
            'description2' => 'd2',
            'start_date' => nil,
            'end_date' => 'THE END!', # <---- bad date
            'is_current' => nil }
        end

        before do
          @corp = create(:corp)
          @params = { 'entity1_id' => @corp.id,
                      'category_id' => 12,
                      'reference' => { 'source' => 'http://example.com', 'name' => 'example.com' },
                      'relationships' => [generic_relationship] }
        end

        it 'does not create a relationship' do
          expect { post :bulk_add, @params }.not_to change { Relationship.count }
        end

        it 'does not create a new entity' do
          expect { post :bulk_add, @params }.not_to change { Entity.count }
        end
      end
    end
  end

  describe 'Permissions' do
    let(:relationship) do
      { 'name' => 'jane doe',
        'blurb' =>  nil,
        'primary_ext' => 'Person',
        'start_date' => '2017-01-01',
        'end_date' => nil,
        'is_current' => nil }
    end

    let(:params) do
      { 'entity1_id' => create(:corp).id,
        'category_id' => 12,
        'reference' => { 'source' => 'http://example.com', 'name' => 'example.com' },
        'relationships' => [relationship] }
    end

    let(:ten_relationships_params) do
      { 'entity1_id' => 1,
        'category_id' => 5,
        'reference' => { 'source' => 'http://example.com', 'name' => 'example.com' },
        'relationships' => [{ 'relationship' => 'details' }] * 10 }
    end

    context 'user not logged in' do
      it 'returns 302' do
        post :bulk_add, ten_relationships_params
        expect(response).to have_http_status(302)
      end
    end

    context 'user with regular permissions' do
      login_basic_user

      it 'allows submission of one relationship' do
        post :bulk_add, params
        json = JSON.parse(response.body)
        expect(response).to have_http_status 200
        expect(json['errors'].length).to eq 0
        expect(json['relationships'].length).to eq 1
      end

      it 'does not allow submission of ten relationships' do
        post :bulk_add, ten_relationships_params
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'user with bulk permissions' do
      login_user
      it 'allows submission of 10 relationships' do
        expect(Entity).to receive(:find).and_return(build(:org))
        expect(controller).to receive(:make_or_get_entity).exactly(10).times
        post :bulk_add, ten_relationships_params
        expect(response).to have_http_status 200
      end
    end
  end

  describe 'make_or_get_entity' do
    login_user
    let(:relationship) { { 'name' => 'new person', 'blurb' => 'words', 'primary_ext' => 'Person', 'is_board' => true } }
    let(:relationship_with_invalid_id) { { 'name' => '987654321', 'blurb' => 'blurb', 'primary_ext' => 'Person' }  } 
    let(:relationship_existing) { { 'name' => '666', 'blurb' => '', 'primary_ext' => 'Person' } }
    let(:relationship_error) { { 'name' => 'i am a cat', 'blurb' => 'meow', 'primary_ext' => nil } }

    specify { expect { |b| controller.send(:make_or_get_entity, relationship, &b) }.to yield_with_args(Entity) }

    def set_controller
      @controller = RelationshipsController.new
      allow(@controller).to receive(:current_user).and_return(double(:sf_guard_user_id => 1234))
      @controller.instance_variable_set(:@errors, [])
    end

    it 'creates new entity' do
      expect { controller.send(:make_or_get_entity, relationship) {} }.to change { Entity.count }.by(1) 
    end

    it' finds existing entity' do
      expect(Entity).to receive(:find_by_id).with(666).and_return(create(:person))
      controller.send(:make_or_get_entity, relationship_existing) {}
    end

    context 'With bad data' do
      before { set_controller }

      specify { expect { |b| @controller.send(:make_or_get_entity, relationship_error, &b) }.not_to yield_control }

      it 'increases error array' do
        expect { @controller.send(:make_or_get_entity, relationship_error) }
          .to change { @controller.instance_variable_get(:@errors).length }.by(1)
      end
    end

    context 'With entity id that does not exist' do
      before { set_controller }

      specify { expect { |b| @controller.send(:make_or_get_entity, relationship_with_invalid_id, &b) }.not_to yield_control }

      it 'increases error count' do
        expect { @controller.send(:make_or_get_entity, relationship_error) }
          .to change { @controller.instance_variable_get(:@errors).length }.by(1)
      end
    end
  end
end
