
TdlHydraHead::Application.routes.draw do
  get "search/index"

  get "contact/index"

  get "about/index"

  match '/imageviewer/:id', :to => 'imageviewer#show', :constraints => {:id => /.*/}, :as =>'imageviewer'
  match "/about" => "about#index"
  match "/search" => "search#index"
  match "/contact" => "contact#index"

#  Blacklight.add_routes(self,
#  map.connect '/catalog/', :controller => 'catalog', :action => 'index'
#    map.connect '/catalog/:id', :controller => 'catalog', :action => 'show', :requirements => { :id => /.*/ }
  #Our pids don't work with the stock blacklight routes, so I added this route
  # When I first made these changes I didn't fully understand the :as piece.
  # :as makes it a named route so you can use catalog_path about_url in the application
  # good info here:
  # http://asciicasts.com/episodes/203-routing-in-rails-3
  match '/catalog/facet/:id', :to => 'catalog#facet', :constraints => {:id => /.*/}, :as =>'catalog'
  match '/catalog/:id', :to => 'catalog#show', :constraints => {:id => /.*/}, :as =>'catalog'
  match '/file_assets/:id', :to => 'file_assets#show', :constraints => {:id => /.*/}, :as =>'file_asset'
  match '/proxy/:id', :to => 'proxy#show', :constraints => {:id => /.*/}, :as =>'proxy'
  #match '/bucketproxy/:id/:index', :to => 'bucketproxy#show', :constraints => {:id => /.*/}, :as =>'bucketproxy'
  #match "/myApi.js" => lambda { |env| [200, {}, "Hello World"] }
  #mount FooBar, :at => '/foo'

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)
  root :to => "catalog#index"

  devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
