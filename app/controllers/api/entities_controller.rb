class Api::EntitiesController < Api::ApiController
  
  def show
    render json: {'entity': 'hello from the entitites controller'}
  end
  
  def relationships
  end

  def details
  end
end
