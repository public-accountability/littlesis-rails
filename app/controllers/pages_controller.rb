class PagesController < ApplicationController
  before_action :set_page, only: :display
  MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                     autolink: true, fenced_code_blocks: true)

  # GET /:page
  def display
  end

  # GET /oligrapher
  # Oligrapher splash page
  def oligrapher_splash
    @maps = NetworkMap.featured.order("updated_at DESC, id DESC").page(params[:page]).per(50)

    @fcc_map = NetworkMap.find(101)
    @lawmaking_map = NetworkMap.find(542)
    @ferguson_map = NetworkMap.find(259)

    @shale_map = NetworkMap.find(152)
    @hadley_map = NetworkMap.find(238)
    @moma_map = NetworkMap.find(282)

    render layout: 'splash'
  end

  def partypolitics
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  private

  

  def set_page
    page_name = Page.pagify_name(params[:page])
    @page = Page.find_by_name(page_name)
    raise Exceptions::NotFoundError if @page.nil?
  end
end
