# frozen_string_literal: true

Rails.application.routes.draw do
  mount MindleapsAnalytics::Engine, at: '/analytics' if defined?(MindleapsAnalytics)

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }, path: '/'
  devise_scope :user do
    post 'sign_in', to: 'users/sessions#token_signin'
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  scope module: :api, as: :api, constraints: ->(req) { req.format == :json } do
    resources :organizations, only: %i[index show]
    resources :chapters, only: %i[index show]
    resources :groups, only: %i[index show]
    resources :students, only: %i[index show]
    resources :lessons, only: %i[index show create]
    resources :grades, only: %i[show create index update destroy]
    resources :subjects, only: %i[index show]
    resources :skills, only: %i[index show]
    resources :grade_descriptors, only: %i[index show]
    resources :assignments, only: %i[index show]
  end

  resources :users, only: %i[index create show update] do
    member do
      put :update_global_role
      delete :revoke_global_role
    end
  end
  resources :organizations, only: %i[index create show] do
    member { post :add_member }
  end
  resources :chapters, only: %i[index create show edit update]
  resources :groups, only: %i[index create show edit update destroy] do
    member { post :undelete }
  end
  resources :students, only: %i[index new create show edit update destroy] do
    resources :student_images, only: %i[index create]
    member do
      post :undelete
    end
  end
  resources :lessons, only: %i[index create show] do
    resources :students, controller: :student_lessons, only: %i[show update]
  end
  resources :subjects, only: %i[index create show edit update]
  resources :skills, only: %i[index create show new]

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
