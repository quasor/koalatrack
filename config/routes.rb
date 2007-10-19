ActionController::Routing::Routes.draw do |map|
  map.resources :groups

  map.resources :tag_favorites

  map.resources :tags

  map.resources :file_attachments

  map.resources :milestones

  map.resources :test_case_executions

  map.resources :playlist_test_cases, :member => { :up => :put, :down => :put }

  map.resources :playlists, :member => {:assign => :put, :pass => :put, :remove => :delete, :sequence => :put}

  map.resources :categories

  map.resources :test_cases

  map.resources :users

  map.resource :session, :controller => 'sessions'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'

  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
#  map.home   '/home', :controller => 
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'TestCases'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
