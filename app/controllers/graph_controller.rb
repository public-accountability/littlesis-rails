class GraphController < ApplicationController
  def all
    respond_to do |format|
      format.json {
        data = open("data/graph.json").read
        render json: JSON.load(data)
      }
    end
  end
end