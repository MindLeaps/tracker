# frozen_string_literal: true

Rails.application.routes.draw do
  mount MindleapsAnalytics::Engine, at: '/analytics' if defined?(MindleapsAnalytics)

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }, path: '/'
  devise_scope :user do
    post 'sign_in', to: 'users/sessions#token_signin'
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  authenticate :user, ->(user) { user.is_super_admin? } do
    mount PgHero::Engine, at: 'pghero'
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

    put '/grades', action: :put_v2, controller: 'grades', as: :put_grade_v2
    delete '/grades/student/:student_id/lesson/:lesson_id/skill/:skill_id', action: :destroy_v2, controller: 'grades', as: :destroy_grade_v2
  end

  scope module: :analytics, path: :analytics do
    match '' => redirect('analytics/general'), via: [:get]
    match 'general' => 'general#index', via: [:get], as: :general_analytics
    match 'subject' => 'subject#index', via: [:get], as: :subject_analytics
    match 'group' => 'group#index', via: [:get], as: :group_analytics
  end

  resources :users, only: %i[index new create destroy show] do
    member do
      post :create_api_token
    end
    resources :memberships, only: %i[update destroy] do
      put :update_global_role, on: :collection
      delete :revoke_global_role, on: :collection
    end
  end
  resources :organizations, only: %i[index new create show] do
    member { post :add_member }
  end
  resources :chapters, only: %i[index new create show edit update]
  resources :groups, only: %i[index new create show edit update destroy] do
    member { post :undelete }
  end

  resources :students, only: %i[index new create edit update destroy] do
    member do
      get 'performance'
      get 'details'
      post :undelete
    end
    resources :student_images, only: %i[index create]
  end
  get '/students/:id', to: redirect('/students/%{id}/performance')

  resources :student_tags, only: %i[index new create show edit update]

  resources :lessons, only: %i[index new create show] do
    resources :students, controller: :student_lessons, only: %i[show update]
  end
  resources :subjects, only: %i[index new create show edit update]
  resources :skills, only: %i[index create show new destroy] do
    member { post :undelete }
  end

  get '/health', controller: 'application', action: :health

  root to: 'home#index'
end
