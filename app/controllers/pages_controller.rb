class PagesController < ApplicationController

  # GET /oligrapher
  # Oligrapher splash page
  def oligrapher_splash
    @maps = NetworkMap.featured.order("updated_at DESC, id DESC").page(params[:page]).per(50)

    @fcc_map = NetworkMap.find(101)
    @ferguson_map = NetworkMap.find(259)

    @shale_map = NetworkMap.find(152)
    @hadley_map = NetworkMap.find(238)
    @moma_map = NetworkMap.find(282)

    @lawmaking_map = NetworkMap.find(542)
    @uc_map = NetworkMap.find(228)
    @goldwyn_map = NetworkMap.find(431)

    @mugabe_map = NetworkMap.find(266)
    @goldman_map = NetworkMap.find(157)
    @berman_map = NetworkMap.find(137)
  end

  
  def partypolitics
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end
end
