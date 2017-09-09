Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

   post 'authenticate', to: 'authentication#authenticate'

   #resources :states #, :defaults => { :format => 'json' } #only: [:index, :new, :create, :edit, :update], constraints: lambda { |req| req.format == :json },

   get 'states', to: 'states#index'

   get 'state/:state_abbreviation', to: 'municipalities#index'
   get 'state/:state_abbreviation/:zone', to: 'municipalities#show'

  #  get 'state/:state_abbreviation/waterways', to: 'waterways#show_all'
   get 'state/:state_abbreviation/:zone/waterways', to: 'waterways#index'

  #  get 'waterways/:state', to: 'waterways#index'

   root to: 'states#index'

end
