Rails.application.routes.draw do
  devise_for :users #, :skip => :registrations
  get 'welcome/index'

  get 'system/index'

  get 'services/index'

  get 'engines/index'
  
  get 'gallery/index'
  
  root 'welcome#index'
  
  resources :services do
    get :pause, :on => :member
        get :unpause, :on => :member
        get :start, :on => :member
        get :stop, :on => :member
        get :restart, :on => :member
        get :show, :on => :member
        get :recreate, :on => :member
        get :create_service, :on => :member
    get :register_site, :on => :member
     get :deregister_site, :on => :member     
    get :register_dns, :on => :member
    get :deregister_dns, :on => :member
  end

    
  resources :gallerys do
    get :list_local, :on => :collection
    get :install_blueprint, :on => :member
    post :install_from_blueprint, :on => :member
  end
  
  resources :engines do
    get :pause, :on => :member
    get :unpause, :on => :member
    get :start, :on => :member
    get :stop, :on => :member
    get :deleteimage, :on => :member
    get :restart, :on => :member
    get :destroy_engine, :on => :member
    get :create_engine, :on => :member
    get :show, :on => :member
    get :monitor, :on => :member
    get :demonitor, :on => :member
    get :register_site, :on => :member
    get :deregister_site, :on => :member
    get :register_dns, :on => :member
    get :deregister_dns, :on => :member
    
  end
  

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
