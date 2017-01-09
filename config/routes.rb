# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength

Rails.application.routes.draw do
  # mount MindleapsAnalytics::Engine, at: '/analytics'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }, path: '/'
  devise_scope :user do
    post 'sign_in', to: 'users/sessions#token_signin'
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  scope module: :api, as: :api, constraints: ->(req) { req.format == :json } do
    resources :organizations, only: [:index, :show]
    resources :chapters, only: [:index, :show]
    resources :groups, only: [:index, :show]
    resources :students, only: [:index, :show]
    resources :lessons, only: [:index, :show, :create]
    resources :grades, only: [:show, :create, :index, :update, :destroy]
    resources :subjects, only: [:index, :show]
    resources :skills, only: [:index, :show]
    resources :grade_descriptors, only: [:index, :show]
    resources :assignments, only: [:index, :show]
  end

  resources :users, only: [:index, :create, :show, :update]
  resources :organizations, only: [:index, :create, :show]
  resources :chapters, only: [:index, :create, :show, :edit, :update]
  resources :groups, only: [:index, :create, :show, :edit, :update]
  resources :students, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    member do
      post :undelete
    end
  end
  resources :lessons, only: [:index, :create, :show] do
    resources :students, controller: :student_lessons, only: [:show, :update]
  end
  resources :subjects, only: [:index, :create, :show, :edit, :update]
  resources :skills, only: [:index, :create, :show, :new]

  root to: 'home#index'

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
