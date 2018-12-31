class PostController < ApplicationController
  before_action :authenticate_user!
  def bulk
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    @facebookActive = Account.find_by(user_id:current_user.id,sns_type:3,active_flg:1)
  end
  def auto
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    @facebookActive = Account.find_by(user_id:current_user.id,sns_type:3,active_flg:1)
  end
end
