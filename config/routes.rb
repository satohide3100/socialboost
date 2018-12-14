Rails.application.routes.draw do
  get 'fav/list'
  get 'unfollow/list'
  get 'follow/list'
  get 'post/bulk'
  get 'post/auto'
  get 'home/top'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
