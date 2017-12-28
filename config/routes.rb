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

  resources :users, only: %i[index create show] do
    resources :memberships, only: %i[update destroy] do
      put :update_global_role, on: :collection
      delete :revoke_global_role, on: :collection
    end
  end
  resources :organizations, only: %i[index create show] do
    member { post :add_member }
  end
  resources :chapters, only: %i[index create show edit update]
  resources :groups, only: %i[index new create show edit update destroy] do
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
end
