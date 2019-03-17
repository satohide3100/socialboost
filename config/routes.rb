Rails.application.routes.draw do
  get 'log/index'
  get 'notification/destroy'
  get 'notification/index'
  get 'analyze/twitter'
  devise_for :users
  root 'account#list'
  get 'fav/list'
  get 'fav/create'
  delete 'fav/:id', to: 'fav#destroy'
  get 'fav/setting_create'
  get 'unfollow/list'
  get 'unfollow/setting_create'
  delete 'unfollow/:id', to: 'unfollow#destroy'
  get 'follow/list'
  get 'follow/create'
  get 'follow/setting_create'
  delete 'follow/:id', to: 'follow#destroy'
  get 'post/bulk'
  get 'post/auto'
  delete 'post/:id', to: 'post#destroy'
  get 'home/top'
  get 'home/test'
  get 'home/setting'
  get 'account/list'
  get 'account/create'
  get 'account/active'
  delete 'account/:id', to: 'account#destroy'
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
