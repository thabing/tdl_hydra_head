class ApplicationController < ActionController::Base
  # Adds Hydra behaviors into the application controller 
   include Hydra::Controller
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 
  before_filter :add_my_own_assets
 
  # look for layout file in /app/views/layouts/tdl.html.erb
  def layout_name
	"tdl"
  end

  def add_my_own_assets
        stylesheet_links << "tdl"

        # You can do something similar with javascript files too:
        # javascript_includes << "my_js"
  end

  protect_from_forgery
end
