require 'rails_helper'

describe EditablePagesController, type: :controller do

  class EditablePagesTestController < EditablePagesController
    page_model ToolkitPage
    namespace 'testnamespace'
  end

  describe 'class configuration' do
    it 'allows configuration of namespace' do
      expect(EditablePagesTestController.namespace).to eql 'testnamespace'
    end

    it 'allows configuration of page_model' do
      expect(EditablePagesTestController.page_model).to eql ToolkitPage
    end

    it 'sets model_param' do
      expect(EditablePagesTestController.instance_variable_get(:@model_param)).to eql 'toolkit_page'
    end
  end

  describe 'editable_page_path' do
    subject { EditablePagesTestController.new }

    it 'returns path with provided name' do
      expect(subject.send(:editable_page_path, 'PAGENAME')).to eql '/testnamespace/PAGENAME'
    end

    it 'returns path with provided name and action' do
      expect(subject.send(:editable_page_path, 'PAGENAME', 'edit')).to eql '/testnamespace/PAGENAME/edit'
    end
  end
end
