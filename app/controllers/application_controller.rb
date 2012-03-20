class ApplicationController < ActionController::Base
  helper BlacklightHelper

  # Adds Hydra behaviors into the application controller 
   include Hydra::Controller
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 
  before_filter :add_remove_js_css, :add_my_own_assets
 
  # look for layout file in /app/views/layouts/tdl.html.erb
  def layout_name
	"tdl-bootstrap"
  end

  def add_remove_js_css
   # javascript_includes.map{|js_links| js_links.delete("accordion") if js_links.include?({:plugin=>:blacklight})}
    #    stylesheet_links << ["mycss",{:media=>"all"}]
  end
  def add_my_own_assets
        stylesheet_links << "tdl"

        # You can do something similar with javascript files too:
        javascript_includes << "tdl"
  end

  protect_from_forgery
end
