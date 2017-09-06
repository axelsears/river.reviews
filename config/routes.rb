Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

   post 'authenticate', to: 'authentication#authenticate'

   #resources :states #, :defaults => { :format => 'json' } #only: [:index, :new, :create, :edit, :update], constraints: lambda { |req| req.format == :json },

   get 'state/:state_abbreviation', to: 'municipalities#index'
   get 'states', to: 'states#index'

  #  get 'waterways/:state', to: 'waterways#index'

   root to: 'states#index'

end
