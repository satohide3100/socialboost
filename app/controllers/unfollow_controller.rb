class UnfollowController < ApplicationController
  before_action :authenticate_user!
  def list
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    if @twitterActive
      @twitterActiveImage = Analyze.find_by(account_id:@twitterActive.id)
      #@follows1 = Follow.where(account_id:@twitterActive.id)
      @twitterSetting = UnFollowSetting.find_by(account_id:@twitterActive.id)
    else
      #@follows1 = []
    end

    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    if @instagramActive
      @instagramActiveImage = Analyze.find_by(account_id:@instagramActive.id)
      @instagramSetting = UnFollowSetting.find_by(account_id:@instagramActive.id)
      interval = @instagramSetting.intervalDay
      intervalDate = Date.today - interval.days
      @unfollows = Follow.where(account_id:@instagramActive.id).where(follow_flg:1).where("updated_at <= ?",intervalDate)
    else
      @unfollows = []
    end

    @facebookActive = Account.find_by(user_id:current_user.id,sns_type:3,active_flg:1)
    if @facebookActive
      @facebookActiveImage = Analyze.find_by(account_id:@facebookActive.id)
      #@follows3 = Follow.where(account_id:@facebookActive.id)
    else
      #@follows3 = []
    end
  end

  def setting_create
    sns_type = params[:sns_type]
    dayLimit = params[:dayLimit]
    interval = params[:interval]
    intervalsec = params[:intervalsec]
    if params[:check]
      checkFlg = 1
    else
      checkFlg = 0
    end
    puts params
    if sns_type == "1"
      @account = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
      account_id = @account.id
    elsif sns_type == "2"
      @account = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
      account_id = @account.id
    end
    unfollowSetting = UnFollowSetting.find_by(account_id:account_id)
    if unfollowSetting == nil
      UnFollowSetting.create(
        dayLimit:dayLimit,intervalDay:interval,intervalsec:intervalsec,checkFlg:checkFlg,account_id:account_id
      )
      flash[:notice] = "アンフォロー設定を新規追加しました。"
    else
      UnFollowSetting.where(account_id:account_id).update(
        dayLimit:dayLimit,intervalDay:interval,intervalsec:intervalsec,checkFlg:checkFlg
      )
      flash[:notice] = "アンフォロー設定を更新しました。"
    end

    redirect_to("/unfollow/list")
  end
end
