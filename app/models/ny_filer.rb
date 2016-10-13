class NyFiler < ActiveRecord::Base
  has_many :ny_filer_entities
  has_many :entities, :through => :ny_filer_entities
  has_many :ny_disclosure, foreign_key: "filer_id"

  def search_filers
    render json: NyFiler.search( search_params[:name], :sql => { :include => :entities })
  end
  
  private
  def search_params
    params.require(:name)
  end
end
