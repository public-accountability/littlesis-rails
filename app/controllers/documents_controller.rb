class DocumentsController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]

  def edit
    @document = Document.find(params[:id])
  end

  def update
    @document = Document.find(params[:id])
    if @document.update_attributes(document_params)
      @document.save!
      redirect_to :back
    else
      render 'edit'
    end
  end

  private

  def document_params
    params.require(:document).permit(:name, :ref_type, :publication_date, :excerpt)
  end
end
