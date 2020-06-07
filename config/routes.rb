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
      get 'export'
      get 'search'
      get 'working_employee'
      get 'edit_basic_info'
      patch 'update_basic_info'
      patch 'update_user_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/request_overtime'
      patch 'attendances/update_overtime'
      get 'attendances/receive_overtime'
      patch 'attendances/decision_overtime'
      get 'attendances/edit_log'
      patch 'attendances/request_one_month'
      get 'attendances/receive_one_month_request'
      patch 'attendances/decision_one_month_attendance'     
      get 'attendances/receive_change_attendance'
      patch 'attendances/update_change_attendance'
    end
    resources :attendances, only: :update
  end
end
  

