describe StreamingController do
  before do
    SwampTip.create!(content: 'foo')
    SwampTip.create!(content: 'bar')
  end

  describe 'Streaming CSV' do
    controller(ApplicationController) do
      include ActionController::Live
      include StreamingController

      def index
        stream_active_record_csv(SwampTip.all)
      end
    end

    before { get :index }

    specify do
      lines = response.body.split("\n")
      expect(lines.size).to eq 3
      expect(lines[0]).to eq "id,content,created_at,updated_at"
      expect(response.body).to include 'foo'
      expect(response.body).to include 'bar'
    end
  end

  describe 'Streaming CSV, skipping buffering, without header' do
    controller(ApplicationController) do
      include ActionController::Live
      include StreamingController

      def index
        stream_active_record_csv(SwampTip.all, include_header: false, no_buffering: true)
      end
    end

    before { get :index }

    specify do
      lines = response.body.split("\n")
      expect(lines.size).to eq 2
      expect(response.body).not_to include 'content'
      expect(response.body).to include 'foo'
      expect(response.body).to include 'bar'
      expect(response.headers['X-Accel-Buffering']).to eq 'no'
    end
  end
end
