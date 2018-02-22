require 'rails_helper'

describe ActionNetwork do
  API_INFO_HASH = JSON.parse(File.read(Rails.root.join('spec', 'testdata', 'action_network_api_info.json'))) # rubocop:disable Metrics/LineLength

  describe 'api_info' do
    it 'returns hash of response' do
      expect(Net::HTTP).to receive(:start)
                             .with('actionnetwork.org', 443, :use_ssl => true)
                             .and_return(API_INFO_HASH)

      expect(ActionNetwork.api_info).to eql API_INFO_HASH
    end
  end

  describe 'signup' do
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:newsletter) { false }
    let(:map_the_power) { false }
    let(:user) do
      build(:user, id: rand(1000), newsletter: newsletter, map_the_power: map_the_power).tap do |user|
        allow(user).to receive(:name_first).and_return(first_name)
        allow(user).to receive(:name_last).and_return(last_name)
      end
    end

    context 'successful signup' do
      let(:mock_http_response) { { 'foo' => 'bar' } }
      before do
        expect(ActionNetwork)
          .to receive(:http).once
                .with(URI.parse(ActionNetwork::PEOPLE_URL), kind_of(Net::HTTP::Post))
                .and_return(mock_http_response)
        expect(Rails.logger).to receive(:debug).with(mock_http_response)
      end

      specify { expect(ActionNetwork.signup(user)).to be true }
    end

    context 'failed signup' do
      before do
        expect(ActionNetwork)
          .to receive(:http).once
                .with(URI.parse(ActionNetwork::PEOPLE_URL), kind_of(Net::HTTP::Post))
                .and_raise(ActionNetwork::HTTPRequestFailedError)
        expect(Rails.logger)
          .to receive(:warn).with("Failed to add user #{user.username}(#{user.id}) to ActionNetwork")
      end

      specify { expect(ActionNetwork.signup(user)).to be false }
    end

    describe 'signup_params' do
      subject { ActionNetwork.signup_params(user) }

      context 'user does not check newsletter or map the power boxes' do
        it do
          is_expected.to eql('person' => {
                               'identifiers' => ["littlesis_user_id:#{user.id}"],
                               'family_name' => last_name,
                               'given_name' => first_name,
                               'email_addresses' => [{ 'address' => user.email }]
                             },
                             'add_tags' => ['LS-Signup'])
        end
      end

      context 'user checks map the power only' do
        let(:map_the_power) { true }
        specify { expect(subject['add_tags']).to eql %w[LS-Signup MTP] }
      end

      context 'user checks map the power and newsletter' do
        let(:map_the_power) { true }
        let(:newsletter) { true }
        specify do
          expect(subject['add_tags']).to eql ['LS-Signup', 'PAI and LittleSis Updates', 'MTP']
        end
      end
    end
  end # end signup
end
