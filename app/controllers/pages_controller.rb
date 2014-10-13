class PagesController < ApplicationController
  def partypolitics
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end
end