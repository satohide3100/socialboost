class FavController < ApplicationController
  before_action :authenticate_user!
  def list
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    if @twitterActive
      @twitterActiveImage = Analyze.find_by(account_id:@twitterActive.id)
      #@follows1 = Follow.where(account_id:@twitterActive.id)
    else
      #@follows1 = []
    end

    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    if @instagramActive
      @instagramActiveImage = Analyze.find_by(account_id:@instagramActive.id)
      #@follows2 = Follow.where(account_id:@instagramActive.id)
    else
      #@follows2 = []
    end

    @facebookActive = Account.find_by(user_id:current_user.id,sns_type:3,active_flg:1)
    if @facebookActive
      @facebookActiveImage = Analyze.find_by(account_id:@facebookActive.id)
      #@follows3 = Follow.where(account_id:@facebookActive.id)
    else
      #@follows3 = []
    end
  end
end
