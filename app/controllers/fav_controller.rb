class FavController < ApplicationController
  before_action :authenticate_user!
  def list
    @twitterActive = Account.where(user_id:current_user.id).where(sns_type:1).where(active_flg:1)
    @twitterActiveImage = Analyze.where(account_id:@twitterActive[0].id)
    @instagramActive = Account.where(user_id:current_user.id).where(sns_type:2).where(active_flg:1)
    @instagramActiveImage = Analyze.where(account_id:@instagramActive[0].id)
  end
end
