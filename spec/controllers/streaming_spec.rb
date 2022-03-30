describe StreamingController do
  describe 'stream_response' do
    controller(ApplicationController) do
      include StreamingController

      def index
        stream_response { %w[foo bar] }
      end
    end

    specify do
      get :index
      expect(response.body).to eq "foobar"
    end
  end

  describe 'stream_response accepts header and prevents buffering' do
    controller(ApplicationController) do
      include StreamingController

      def index
        stream_response(before: "data", no_buffering: true) { %w[foo bar] }
      end
    end

    specify do
      get :index
      expect(response.body).to eq "datafoobar"
      expect(response.headers['X-Accel-Buffering']).to eq 'no'
    end
  end

  describe 'stream_active_record_csv' do
    before do
      SwampTip.create!(content: 'foo')
      SwampTip.create!(content: 'bar')
    end

    controller(ApplicationController) do
      include StreamingController

      def index
        stream_active_record_csv(SwampTip.all)
      end
    end

    specify do
      get :index
      lines = response.body.split("\n")
      expect(lines.size).to eq 3
      expect(lines[0]).to eq "id,content,created_at,updated_at"
      expect(response.body).to include 'foo'
      expect(response.body).to include 'bar'
    end
  end
end
