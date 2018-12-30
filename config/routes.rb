Rails.application.routes.draw do
  devise_for :users
  root 'account#list'
  get 'fav/list'
  get 'unfollow/list'
  get 'follow/list'
  get 'follow/create'
  get 'post/bulk'
  get 'post/auto'
  get 'home/top'
  get 'home/setting'
  get 'account/list'
  get 'account/create'
  get 'account/active'
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
