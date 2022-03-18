# frozen_string_literal: true

class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :current_user_can_edit?
  before_action :set_document

  def edit
  end

  def update
    @document.assign_attributes(document_params)
    if @document.valid?
      @document.save!
      redirect_to home_dashboard_path
    else
      redirect_to edit_document_path(@document)
    end
  end

  private

  def set_document
    @document = Document.find(params[:id].to_i)
  end

  def document_params
    doc_params = params.require(:document).permit(:name, :ref_type, :publication_date, :excerpt)
    doc_params['publication_date'] = LsDate.convert(doc_params['publication_date'])
    blank_to_nil(doc_params)
  end
end
