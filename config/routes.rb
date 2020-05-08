Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # 拠点情報
  resources :bases, except: [:show, :new]
  
  resources :users do
    collection { post :import }
    get 'import'
    member do
      get 'search'
      get 'working_employee'
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'edit_overtime'
      patch 'update_overtime'
      patch 'update_user_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
    end
    resources :attendances, only: :update
  end
  
end
