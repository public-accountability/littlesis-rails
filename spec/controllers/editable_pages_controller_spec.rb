require 'rails_helper'

describe EditablePagesController, type: :controller do

  class TestController < EditablePagesController
    page_model ToolkitPage
    namespace 'testnamespace'
  end

  describe 'class configuration' do
    it 'allows configuration of namespace' do
      expect(TestController.namespace).to eql 'testnamespace'
    end

    it 'allows configuration of page_model' do
      expect(TestController.page_model).to eql ToolkitPage
    end

    it 'sets model_param' do
      expect(TestController.instance_variable_get(:@model_param)).to eql 'toolkit_page'
    end
  end
end
