require 'rails_helper'

describe Api do
  before(:all) do
    @user = create_really_basic_user
    @api_token = @user.create_api_token!
    @auth_header = { 'Littlesis-Api-Token': @api_token.token }
  end

  after(:all) do
    @user.sf_guard_user.delete
    @user.delete
    @api_token.delete
  end

  let(:meta) do
    {
      'copyright' => ApiUtils::ApiResponseMeta::META[:copyright],
      'license' => ApiUtils::ApiResponseMeta::META[:license],
      'apiVersion' => ApiUtils::ApiResponseMeta::META[:apiVersion]
    }
  end

  describe 'entities' do
    let(:lawyer) do
      create(:entity_person).tap { |e| e.add_extension('Lawyer') }
    end

    describe 'entity information /entities/:id' do
      before { get api_entity_path(lawyer), {}, @auth_header }
      specify { expect(response).to have_http_status 200 }

      

      it 'returns json of model' do
        expected =  {
          'data' => {
            'type' => 'entities',
            'id' => lawyer.id,
            'attributes' => {
              'name' => lawyer.name,
              'blurb' => lawyer.blurb,
              'primary_ext' => 'Person',
              'summary' => lawyer.summary,
              'parent_id' => nil,
              'website' => lawyer.website,
              'start_date' => lawyer.start_date,
              'end_date' => lawyer.end_date,
              'types' => ["Person", "Lawyer"],
              'aliases' => lawyer.aliases.map(&:name),
              'updated_at' => lawyer.updated_at.iso8601
            }
          },
          'links' => { 'self' => Rails.application.routes.url_helpers.entity_url(lawyer) },
          'meta' => meta
        }
        expect(json).to eql(expected)
      end
    end
  end
end
