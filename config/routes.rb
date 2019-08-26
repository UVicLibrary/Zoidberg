Rails.application.routes.draw do
  resources :documents, only: [:index, :new, :create, :show]

  # resources :profiles
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'documents#new'
end
