describe RecordHistory do
  describe 'initalize' do
    it 'stores model name on instance variable' do
      test_class = Class.new(RecordHistory) { model_name :test_class }
      test_record = Object.new
      test_instance = test_class.new(test_record)

      expect(test_class.const_get(:MODEL_NAME)).to be :test_class
      expect(test_instance.test_class).to be test_record
    end
  end
end
